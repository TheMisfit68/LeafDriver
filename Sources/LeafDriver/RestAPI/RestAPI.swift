//
//  RestAPI.swift
//  
//
//  Created by Jan Verrept on 18/04/2020.
//

import Foundation
import Combine

//TODO: - Add this Class to JVCocoa
@available(OSX 10.15, *)
public class RestAPI<E:StringRepresentableEnum, P:StringRepresentableEnum>{
    
    public enum RESTmethod:String {
        case GET
        case POST
        case PUT
        case DELETE
    }
    
    var baseURL:String
    var endpointParameters:[E:[P]]
    var baseParameters:[P:String]
    
    
    public init(baseURL:String, endpointParameters:[E:[P]], baseParameters:[P:String] = [:]){
        
        self.baseURL = baseURL
        self.endpointParameters = endpointParameters
        self.baseParameters = baseParameters
        
    }
    
    public func publish<T:Decodable>(command:E, parameters:[P:String], maxRetries:Int = 2, retryDelay:UInt32 = 2)->AnyPublisher<T?, Error>{
        
        let url = URL(string:baseURL+command.stringValue)
        var request = URLRequest(url: url!)
        request.httpMethod = RESTmethod.POST.rawValue
        request.allHTTPHeaderFields = ["Content-Type" : "application/x-www-form-urlencoded"]
        let parameters = baseParameters.merging(parameters) {$1}
        let form = HTTPForm(parametersToInclude: endpointParameters[command] ?? [], currentParameters: parameters)
        let body = form.composeBody(type: .Form)
        request.httpBody = body
        print()
        print("🔃 Publishing \(command.rawValue)")
        if let printableBody = form.composeBody(type: .Custom(seperator: "\n")), let bodyDescription = String(data:printableBody,encoding: .utf8){
            print(bodyDescription)
            print()
        }
        return DecodingPublisher.Publisher(from: request, maxRetries: maxRetries, retryDelay:retryDelay)
    }
    
}

struct HTTPForm<P:StringRepresentableEnum>{
    
    var parametersToInclude:[P]
    public var currentParameters:[P:String]
    
    public enum HTTPbodyType{
        case Json
        case Form
        case Custom(seperator:String)
    }
    
    public static func Encode(_ parameter:String)->String{
        
        var encodedParameter = parameter
        encodedParameter = encodedParameter.replacingOccurrences(of: "/", with: "%2F")
        encodedParameter = encodedParameter.replacingOccurrences(of: "+", with: "%2B")
        encodedParameter = encodedParameter.replacingOccurrences(of: "=", with: "%3D")
        
        return encodedParameter
    }
    
    public func composeBody(type:HTTPbodyType = .Json)->Data?{
        
        let  filteredParameters = currentParameters.filter { (parameterName, parameterValue) in parametersToInclude.contains(parameterName)}
        let  stringRepresentations = filteredParameters.map {(parameterName, parameterValue) in (parameterName.stringValue, parameterValue)}
        
        switch type {
        case .Json:
            return try? JSONSerialization.data(withJSONObject: stringRepresentations, options: .prettyPrinted)
        case .Form:
            let parametersAndValues = stringRepresentations.map {parameterName, parameterValue in return "\(parameterName)=\(parameterValue)" }
            let paramaterString = parametersAndValues.joined(separator: "&")
            return paramaterString.data(using: .utf8)
        case .Custom(let seperator):
            let parametersAndValues = stringRepresentations.map {parameterName, parameterValue in "\(parameterName)=\(parameterValue)" }
            let paramaterString = parametersAndValues.joined(separator: seperator)
            return paramaterString.data(using: .utf8)
        }
        
    }
    
}



