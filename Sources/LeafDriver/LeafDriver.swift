//
//  LeafDriver.swift
//
//
//  Created by Jan Verrept on 26/03/2020.
//


import Foundation
import JVCocoa
import Combine
import CryptoSwift
import SiriDriver


internal enum LeafDriverError:LocalizedError{
    case noResponse
}

@available(OSX 10.15, *)
public class LeafDriver{
    
    public typealias AnyMethod = ()->()
    public var commandQueue: [LeafCommand:AnyMethod] = [:]
    
    var restAPI:RestAPI<LeafCommand, LeafParameter>
    
    public let siriDriver = SiriDriver(language: .flemish)
    public enum ConnectionState:Int, Comparable{
        
        case disconnected
        case connected
        case loggedIn
        case unknown
        
        // Conform to comparable
        public static func < (a: ConnectionState, b: ConnectionState) -> Bool {
            return a.rawValue < b.rawValue
        }
    }
    
    public var connectionState:ConnectionState = .disconnected{
        
        // Acts as a state engine
        didSet{
            
            switch connectionState {
            case .unknown:
                connect()
            case .disconnected:
                connect()
            case .connected:
                login()
            case .loggedIn:
                commandQueue.forEach{ command, associatedMethod in
                    associatedMethod()
                }
            }
        }
    }
    
    public var batteryChecker:BatteryChecker!
    public var acController:ACController!
    public var charger:Charger!
    
    
    let standardUserDefaults = UserDefaults.standard
    
    var connectionPublisher:AnyPublisher<ConnectionInfo?, Error>!
    var connectionReceiver:Cancellable!
    
    var logginPublisher:AnyPublisher<Session?, Error>!
    var loginReceiver:Cancellable!
    
    var connectionInfo:ConnectionInfo?
    var session:Session?
    
    var parameters:[LeafParameter:String]{
        
        var currentParameters:[LeafParameter:String] = [:]
        var currentParameter:LeafParameter
        
        func encryptUsingBlowfish(password:String, key:String)->String{
            
            let password = Array(password.utf8)
            let key = Array(key.utf8)
            
            let blowFishEncryptor = try? Blowfish(key: key, blockMode: ECB(), padding: .pkcs5)
            let encryptedPassword =  try? blowFishEncryptor?.encrypt(password).toBase64()
            return encryptedPassword ?? ""
            
        }
        
        // User
        // UserID
        currentParameter = LeafParameter.userID
        if let currentValue = session?.customerInfo.eMailAddress{
            currentParameters[currentParameter] = currentValue
        }
        
        // Password
        currentParameter = LeafParameter.password
        if let clearPassword = restAPI.baseParameters[.clearPassword], let encryptionkey = connectionInfo?.baseprm{
            let currentValue = encryptUsingBlowfish(password: clearPassword, key:encryptionkey)
            currentParameters[currentParameter] = currentValue
        }
        
        // RegionCode
        currentParameter = LeafParameter.regionCode
        if let currentValue = session?.customerInfo.regionCode{
            currentParameters[currentParameter] = currentValue
        }
        
        // Timezone
        currentParameter = LeafParameter.timeZone
        if let currentValue = session?.customerInfo.timezone{
            currentParameters[currentParameter] = currentValue
        }
        
        // Language
        currentParameter = LeafParameter.language
        if let currentValue = session?.customerInfo.language{
            currentParameters[currentParameter] = currentValue
        }
        
        
        
        // Session
        // SessionID
        currentParameter = LeafParameter.customSessionID
        if let currentValue = session?.vehicleInfoList.vehicleInfoListVehicleInfo.first?.customSessionid{
            currentParameters[currentParameter] = currentValue
        }
        
        // Vehicle
        // VIN
        currentParameter = LeafParameter.vin
        if let currentValue = session?.vehicleInfoList.vehicleInfoListVehicleInfo.first?.vin{
            currentParameters[currentParameter] = currentValue
        }
        
        // DCMID
        currentParameter = LeafParameter.dcmid
        if let currentValue = session?.vehicle.profile.dcmId{
            currentParameters[currentParameter] = currentValue
        }
        
        return currentParameters
    }
    
    public init(leafProtocol:LeafProtocol){
        
        let userSettings:[String:Any] = standardUserDefaults.dictionary(forKey: "LeafSettings") ?? [:]
        var userParameters:[LeafParameter:String] = [.initialAppStr: leafProtocol.initialAppString]
        
        // If no userdefaults present yet, provide some for testing purposes
        userParameters[.userID] = userSettings["UserName"] as? String ?? "myUserName"
        userParameters[.clearPassword]  = userSettings["Password"] as? String ?? "myClearPassword"
        
        userParameters[.regionCode] = userSettings["RegionCode"] as? String ?? Region.europe.rawValue
        userParameters[.language] = userSettings["Language"] as? String ?? Language.flemish.rawValue
        userParameters[.timeZone] = userSettings["TimeZone"] as? String ?? TimeZone.brussels.rawValue
        
        restAPI = RestAPI<LeafCommand, LeafParameter>(baseURL: leafProtocol.baseURL, endpointParameters: leafProtocol.requiredCommandParameters,baseParameters: userParameters)
        
        batteryChecker = BatteryChecker(mainDriver: self)
        acController = ACController(mainDriver: self)
        charger = Charger(mainDriver: self)
        self.connect()
    }
    
    
    private func connect(){
        
        let thisCommand:LeafCommand = .connect
        let thisMethod = connect
        
        connectionPublisher = restAPI.publish(method:.POST, command: thisCommand, parameters: parameters, maxRetries: 5)
        connectionReceiver = connectionPublisher
            .sink(receiveCompletion: {completion in
                self.handle(completion: completion, of: thisCommand, recalOnFailure: thisMethod, callwhenSucceeded: {})
            },receiveValue: {value in
                if let connectionResult = value{
                    self.connectionInfo = connectionResult
                    self.connectionState = .connected
                }
            }
            )
    }
    
    
    private func login(){
        
        let thisCommand:LeafCommand = .login
        let thisMethod = login
        
        logginPublisher = restAPI.publish(method:.POST, command: thisCommand, parameters: parameters, retryDelay: 5)
        
        loginReceiver = logginPublisher
            .sink(receiveCompletion: {completion in
                self.handle(completion: completion, of: thisCommand, recalOnFailure: thisMethod, callwhenSucceeded: {})
            },receiveValue: {value in
                if let loginResult = value{
                    self.session = loginResult
                }
            }
            )
    }
    
    internal func handle(completion:Subscribers.Completion<Error>,of command:LeafCommand, recalOnFailure:@escaping AnyMethod, callwhenSucceeded:@escaping AnyMethod){
        
        switch completion{
        case .finished:
            
            commandQueue.removeValue(forKey: command)
            commandQueue[command] = callwhenSucceeded
            
            if command == .connect {
                connectionState = max(connectionState, .connected)
            }else{
                connectionState = max(connectionState, .loggedIn)
            }
            
        case .failure(let error):
            
            commandQueue[command] = recalOnFailure
            
            switch error{
            case URLError.notConnectedToInternet:
                connectionState = min(connectionState, .disconnected)
            case DecodingError.keyNotFound:
                if command == .connect {
                    connectionState = min(connectionState, .disconnected)
                }else if command == .login{
                    connectionState = min(connectionState, .connected)
                }else{
                    connectionState = min(connectionState, .loggedIn)
                }
            default:
                connectionState = .unknown
            }
            
        }
    }
    
    
}
