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

@available(OSX 12.0, *)
extension LeafDriver:PreferenceBased{
    public var preferencesRootKey:String{ "LeafSettings" }
}


@available(OSX 12.0, *)
open class LeafDriver:Securable{
    
    internal enum Error:LocalizedError{
        case noResponse
    }
    
    public typealias AnyMethod = ()->()
    public typealias LeafAPI = RestAPI<LeafCommand, LeafParameter>
    public var commandQueue: [LeafCommand:AnyMethod] = [:]
    
    var restAPI:LeafAPI!
    
    var connectionPublisher:AnyPublisher<ConnectionInfo?, Swift.Error>!
    var connectionReceiver:Cancellable!
    
    var logginPublisher:AnyPublisher<Session?, Swift.Error>!
    var loginReceiver:Cancellable!
    
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
                    print("🐞\t decueing \(command)") // TODO: - remove temp print statement
                    
                    associatedMethod()
                }
            }
        }
    }
    
    public var batteryChecker:BatteryChecker!
    public var acController:ACController!
    public var charger:Charger!
    
    
    
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
        currentParameter = LeafParameter.encryptedPassWord
        if let clearPassWord:String = restAPI.baseValues[.clearPassWord],
           let encryptionkey:String = connectionInfo?.baseprm{
            let currentValue = encryptUsingBlowfish(password: clearPassWord, key:encryptionkey)
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
        
        // Read the credentials
        let userName:String = preferences?[keyPath:"UserName"] as? String ?? "myUserName"
        let clearPassWord:String = passwordFromKeyChain(withTag:"LeafDriver", accountName: userName) ?? "myPassWord"
        
        // Read te parameters from the Preferences…
        let userParameters:[LeafParameter:String] = [
            .initialAppStr: leafProtocol.initialAppString,
            .userID: userName,
            .clearPassWord: clearPassWord,
            .regionCode: preferences?[keyPath:"regionCode"] as? String ?? Region.europe.rawValue,
            .language: preferences?[keyPath:"language"] as? String ?? Language.flemish.rawValue,
            .timeZone: preferences?[keyPath:"timeZone"] as? String ?? TimeZone.brussels.rawValue
        ]
        restAPI = RestAPI<LeafCommand, LeafParameter>(baseURL: leafProtocol.baseURL, endpointParameters: leafProtocol.requiredCommandParameters, baseValues: userParameters)
        
        batteryChecker = BatteryChecker(mainDriver: self)
        acController = ACController(mainDriver: self)
        charger = Charger(mainDriver: self)
        self.connect()
        
    }
    
    
    private func connect(){
        
        let thisCommand:LeafCommand = .connect
        let thisMethod = connect
        
        
        Task{
            do {
                self.connectionInfo = try await restAPI.decode(method:RestAPI.Method.POST, command: thisCommand, parameters: parameters)
                commandQueue.removeValue(forKey: thisCommand)
                connectionState = max(connectionState, .connected)
            } catch {
                commandQueue[thisCommand] = thisMethod
                connectionState = min(connectionState, .disconnected)
            }
        }
        
    }
    
    
    
    private func login(){
        
        let thisCommand:LeafCommand = .login
        let thisMethod = login
        
        
        Task{
            do {
                self.session = try await restAPI.decode(method:RestAPI.Method.POST, command: thisCommand, parameters: parameters)
                commandQueue.removeValue(forKey: thisCommand)
                connectionState = max(connectionState, .loggedIn)
            } catch LeafAPI.Error.statusError{
                commandQueue[thisCommand] = thisMethod
                connectionState = min(connectionState, .disconnected)
            }	catch LeafAPI.Error.decodingError{
                commandQueue[thisCommand] = thisMethod
                connectionState = min(connectionState, .connected)
            }
        }
        
    }
    
    
}

