import Foundation
import Combine
import CryptoSwift

@available(OSX 10.15, *)
public class LeafDriver{
    
    var restAPI:RestAPI<LeafCommand, LeafParameter>
    let standardUserDefaults = UserDefaults.standard
    
    var encryptionKey:EncryptionKey?
    var connectionPublisher:AnyPublisher<EncryptionKey?, Error>!
    var connectionReceiver:Cancellable!
    
    var session:Session?
    var logginPublisher:AnyPublisher<Session?, Error>!
    var loginReceiver:Cancellable!
    
    var battery:Battery?
    var batteryStatsPublisher:AnyPublisher<Battery?, Error>!
    var batteryStatsReceiver:Cancellable!
    
    typealias FunctionPointer = ()->()
    typealias MaxRetryCount = Int
    var commandQueue:[LeafCommand:(FunctionPointer, MaxRetryCount)] = [:]
    
    private enum ConnectionState:Int, Comparable{
        
        case disconnected
        case connected
        case loggedIn
        case failed
        
        // Conform to comparable
        public static func < (a: ConnectionState, b: ConnectionState) -> Bool {
            return a.rawValue < b.rawValue
        }
    }
    
    
    private var connectionState:ConnectionState = .disconnected{
        
        // Acts as a state engine
        didSet{
            
            switch connectionState {
                
            case .disconnected:
                connect()
            case .connected:
                login()
            case .loggedIn:
                if !commandQueue.isEmpty{
                    commandQueue.forEach{ command, queueInfo in
                        let funtionToCall = queueInfo.0
                        funtionToCall()
                    }
                }
            case .failed:
                connect()
            }
        }
    }
    
    
    
    public init(leafProtocol:LeafProtocol){
        
        let userSettings:[String:Any] = standardUserDefaults.dictionary(forKey: "LeafSettings") ?? [:]
        var userParameters:[LeafParameter:String] = [.initialAppStr: leafProtocol.initialAppString]
        
        // if no userdefaults present yet, provide some for testing purposes
        userParameters[.regionCode] = userSettings["RegionCode"] as? String ?? Region.europe.rawValue
        userParameters[.language] = userSettings["Language"] as? String ?? Language.flemish.rawValue
        userParameters[.userID] = userSettings["UserName"] as? String ?? "myUserName"
        userParameters[.clearPassword]  = userSettings["Password"] as? String ?? "myClearPassword"
        
        self.restAPI = RestAPI(baseURL: leafProtocol.baseURL, endpointParameters: leafProtocol.requiredCommandParameters, defaultParameters:userParameters)
        self.connect()
    }
    
    public func getBatteryStatus(){
        
        if self.connectionState == .loggedIn{
            updateParameters()
            batteryStatsPublisher = restAPI.publish(command: .batteryStatus)
            batteryStatsReceiver = batteryStatsPublisher.assertNoFailure().sink(receiveCompletion: {completion in},
                                                                                receiveValue: {value in
                                                                                    self.battery = value
                                                                                    if self.battery != nil{
                                                                                        self.removeFromQueue(command: .batteryStatus)
                                                                                        print(self.battery!)
                                                                                        self.connectionState = .loggedIn
                                                                                    }else{
                                                                                        self.addToQueue(command: .batteryStatus, function: self.getBatteryStatus,maxRetries: 2)
                                                                                        self.connectionState = .failed
                                                                                    }
            }
            )
        }else{
            self.addToQueue(command: .batteryStatus, function: self.getBatteryStatus)
        }
        
    }
    
    private func connect(){
        
        updateParameters()
        connectionPublisher = restAPI.publish(command: .connect)
        
        connectionReceiver = connectionPublisher.sink(receiveCompletion: {completion in},
                                                      receiveValue: {value in
                                                        self.encryptionKey = value
                                                        if self.encryptionKey != nil{
                                                            self.connectionState = .connected
                                                        }
        }
        )
    }
    
    private func login(){
        
        updateParameters()
        logginPublisher = restAPI.publish(command: .login)
        
        loginReceiver = logginPublisher.sink(receiveCompletion: {completion in},
                                             receiveValue: {value in
                                                self.session = value
                                                if self.session != nil{
                                                    self.connectionState = .loggedIn
                                                }
        }
        )
        
    }
    
    private func addToQueue(command:LeafCommand, function:@escaping FunctionPointer, maxRetries:MaxRetryCount = 1){
        
        if commandQueue[command] == nil{
            commandQueue[command] = (function, maxRetries)
        }else if let currentEntry = commandQueue[command]{
            let retriesLeft = currentEntry.1-1
            commandQueue[command] = (function, retriesLeft)
            if retriesLeft > 0{
            }else{
                commandQueue.removeValue(forKey:command)
            }
        }
    }
    
    private func removeFromQueue(command:LeafCommand){
        if commandQueue[command] != nil{
            commandQueue.removeValue(forKey:command)
        }
    }
    
    
    private func updateParameters(){
        
        var parameter:LeafParameter
        
        func encryptUsingBlowfish(password:String, key:String)->String{
            
            let password = Array(password.utf8)
            let key = Array(key.utf8)
            
            let blowFishEncryptor = try? Blowfish(key: key, blockMode: ECB(), padding: .pkcs5)
            let encryptedPassword =  try? blowFishEncryptor?.encrypt(password).toBase64()
            return encryptedPassword ?? ""
            
        }
        
        // SessionID
        // UserID
        parameter = LeafParameter.customSessionID
        
        if let parameterValue = session?.vehicleInfoList.vehicleInfoListVehicleInfo.first?.customSessionid{
            restAPI.form.parameters[parameter] = restAPI.form.encode(parameterValue)
        }
        
        // UserID
        parameter = LeafParameter.userID
        if let parameterValue = session?.customerInfo.eMailAddress{
            restAPI.form.parameters[parameter] = parameterValue
        }
        
        // Encrypted password
        parameter = LeafParameter.password
        if let clearPassword = restAPI.form.parameters[LeafParameter.clearPassword], let encryptionkey = encryptionKey?.baseprm{
            let parameterValue = encryptUsingBlowfish(password: clearPassword, key:encryptionkey)
            restAPI.form.parameters[parameter] = parameterValue
        }
        
        // VIN
        parameter = LeafParameter.vin
        if let parameterValue = session?.vehicle.profile.vin{
            restAPI.form.parameters[parameter] = parameterValue
        }
        
        // DCMID
        parameter = LeafParameter.dcmid
        if let parameterValue = session?.vehicle.profile.dcmid{
            restAPI.form.parameters[parameter] = parameterValue
        }
        
        // Timezone
        parameter = LeafParameter.timeZone
        if let parameterValue = session?.customerInfo.timezone{
            restAPI.form.parameters[parameter] = parameterValue
        }
        
        // TimeFrom
        //             parameter = LeafParameter.timeFrom
        //        if let parameterValue = session?.customerInfo.vehicleInfo.userVehicleBoundTime{
        //                 restAPI.form.parameters[parameter] = parameterValue
        //             }
    }
    
}
