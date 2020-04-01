import Foundation
import CryptoSwift

public class LeafDriver{
    
    typealias CompletionHandler = (String) -> Void
    
    // Addopt to the LeafProtocol
    var protocolDefinition:LeafProtocol
    let standardUserDefaults = UserDefaults.standard
    var commandParameters:[LeafParameter: String] = [:]
    
    var session:Session!
    
    public init(leafProtocol:LeafProtocol){
        
        self.protocolDefinition = leafProtocol
        
        let leafSettings = standardUserDefaults.dictionary(forKey: "LeafSettings") ?? [:]
        
        self.commandParameters[.regionCode] = leafSettings["RegionCode"] as? String ?? ""
        self.commandParameters[.userID] = leafSettings["UserName"] as? String ?? ""
        self.commandParameters[.password] = leafSettings["Password"] as? String ?? ""
        
    }
    
    public func connect(){
        
        commandParameters[.initialAppStr] = protocolDefinition.initialAppString
        execute(command: .connect){jsonString in
            
            if let encryptionKey = try? EncryptionKey(jsonString){
                
                // Replace the password with the encrypted version
                let clearPassword = self.commandParameters[.password] ?? ""
                self.commandParameters[.password] = self.encryptUsingBlowfish(password: clearPassword, key: encryptionKey.baseprm)
                self.login()
            }
            
        }
        
    }
    
    public func getBatteryStatus(){
          
        execute(command: .batteryStatus){jsonString in
            
            if let session = try? Session(jsonString){
                print(session.vehicle.profile.nickname)
            }
            
        }
          
    }
    
    private func login(){
       
           execute(command: .login){jsonString in
               
               if let session = try? Session(jsonString){
                self.session = session
                print(self.session.vehicle.profile.nickname)
               }
               
           }
       }
    
    private func execute(command:LeafCommand, completionHandler: @escaping CompletionHandler) {
        
        // Post request
        let url = URL(string: protocolDefinition.baseURL+command.rawValue)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.httpBody = composeBody(for: command)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("error: \(error)")
            } else if let data = data{
                // Parse the received data
                if let json = String(data: data, encoding: .utf8){
                    
                    completionHandler(json)
                }
            }
        }
        task.resume()
    }
    
    private func composeBody(for command: LeafCommand)->Data?{
        
        var parameterString:String = ""
        if let parametersToAppend:[LeafParameter] = protocolDefinition.commands[command]{
            let parametersAndValues:[String] = parametersToAppend.map{ leafParameter in
                let parameterName:String = leafParameter.rawValue
                let parameterValue = commandParameters[leafParameter] ?? ""
                return "\(parameterName)=\(parameterValue)"
            }
            parameterString = parametersAndValues.joined(separator: "&")
        }
        return parameterString.data(using: .utf8)
        
    }
    
    private func encryptUsingBlowfish(password:String, key:String)->String?{
        
        let password = Array(password.utf8)
        let key = Array(key.utf8)
        
        let blowFishEncryptor = try? Blowfish(key: key, blockMode: ECB(), padding: .pkcs5)
        return try? blowFishEncryptor?.encrypt(password).toBase64()
        
    }
    
    
}

