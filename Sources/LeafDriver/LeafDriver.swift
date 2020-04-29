import Foundation
import Combine
import CryptoSwift
import SiriDriver

@available(OSX 10.15, *)
public class LeafDriver:RestAPI<LeafCommand, LeafParameter>{
    
    public let siriDriver = SiriDriver(language: .flemish)
    public enum ConnectionState:Int, Comparable{
        
        case disconnected
        case connected
        case loggedIn
        case failed
        
        // Conform to comparable
        public static func < (a: ConnectionState, b: ConnectionState) -> Bool {
            return a.rawValue < b.rawValue
        }
    }
    
    public var connectionState:ConnectionState = .disconnected{
        
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
                        sleep(2)
                    }
                }
            case .failed:
                connect()
            }
        }
    }
    
    public var batteryChecker:BatteryChecker!
    public var acController:ACController!
    public var charger:Charger!
    
    public typealias FunctionPointer = ()->()
    public typealias MaxRetryCount = Int
    public var commandQueue:[LeafCommand:(FunctionPointer, MaxRetryCount)] = [:]
    
    let standardUserDefaults = UserDefaults.standard
    
    var connectionPublisher:AnyPublisher<ConnectionInfo?, Error>!
    var connectionReceiver:Cancellable!
    
    var logginPublisher:AnyPublisher<Session?, Error>!
    var loginReceiver:Cancellable!
    
    var connectionInfo:ConnectionInfo?
    var session:Session?
    
    var parameters:[LeafParameter:String]{
        
        var currentParameter:LeafParameter
        var currentParameters:[LeafParameter:String] = baseParameters
        
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
        
        // Clear password
        currentParameter = LeafParameter.password
        if let clearPassword = currentParameters[.clearPassword], let encryptionkey = connectionInfo?.baseprm{
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
            currentParameters[currentParameter] = HTTPForm<LeafParameter>.Encode(currentValue)
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
            currentParameters[currentParameter] = HTTPForm<LeafParameter>.Encode(currentValue)
        }
        
        return currentParameters
    }
    
    public init(leafProtocol:LeafProtocol){
        
        let userSettings:[String:Any] = standardUserDefaults.dictionary(forKey: "LeafSettings") ?? [:]
        var userParameters:[LeafParameter:String] = [.initialAppStr: leafProtocol.initialAppString]
        
        // if no userdefaults present yet, provide some for testing purposes
        userParameters[.userID] = userSettings["UserName"] as? String ?? "myUserName"
        userParameters[.clearPassword]  = userSettings["Password"] as? String ?? "myClearPassword"
        
        userParameters[.regionCode] = userSettings["RegionCode"] as? String ?? Region.europe.rawValue
        userParameters[.language] = userSettings["Language"] as? String ?? Language.flemish.rawValue
        userParameters[.timeZone] = userSettings["TimeZone"] as? String ?? TimeZone.brussels.rawValue
        
        super.init(baseURL: leafProtocol.baseURL, endpointParameters: leafProtocol.requiredCommandParameters, baseParameters:userParameters)
        
        batteryChecker = BatteryChecker(mainDriver: self)
        acController = ACController(mainDriver: self)
        charger = Charger(mainDriver: self)
        self.connect()
    }
    
    internal func addToQueue(command:LeafCommand, function:@escaping FunctionPointer, maxRetries:MaxRetryCount = 1){
        
        if commandQueue[command] == nil{
            commandQueue[command] = (function, maxRetries)
        }else if let currentEntry = commandQueue[command]{
            let retriesLeft = currentEntry.1-1
            commandQueue[command] = (function, retriesLeft)
            if retriesLeft > 0{
            }else{
                removeFromQueue(command: command)
            }
        }
    }
    
    internal func removeFromQueue(command:LeafCommand){
        if commandQueue[command] != nil{
            commandQueue.removeValue(forKey:command)
        }
    }
    
    
    private func connect(){
        
        connectionPublisher = publish(command: .connect, parameters: parameters)
        
        connectionReceiver = connectionPublisher.sink(receiveCompletion: {completion in},
                                                      receiveValue: {value in
                                                        if let connectionResult = value{
                                                            self.connectionInfo = connectionResult
                                                            self.connectionState = .connected
                                                        }
        }
        )
    }
    
    private func login(){
        
        logginPublisher = publish(command: .login, parameters: parameters)
        
        loginReceiver = logginPublisher.sink(receiveCompletion: {completion in},
                                             receiveValue: {value in
                                                if let loginResult = value{
                                                    self.session = loginResult
                                                    self.connectionState = .loggedIn
                                                }
        }
        )
        
    }
    
}

