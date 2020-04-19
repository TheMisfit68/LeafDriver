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
class RestAPI<E:StringRepresentableEnum, P:StringRepresentableEnum>{
    
    public enum RESTmethod:String {
        case GET
        case POST
        case PUT
        case DELETE
    }
    
    var baseURL:String
    public var endpointParameters:[E:[P]]
    public var form:HTTPForm<P>
        
    public init(baseURL:String, endpointParameters:[E:[P]], defaultParameters:[P:String] = [:]){
        
        self.baseURL = baseURL
        self.endpointParameters = endpointParameters
        self.form = HTTPForm(parameters: defaultParameters)
        
    }
    
    public func publish<T:Decodable>(command:E)->AnyPublisher<T?, Error>{
        
        let url = URL(string:baseURL+command.stringValue)
        
        var request = URLRequest(url: url!)
        request.httpMethod = RESTmethod.POST.rawValue
        request.allHTTPHeaderFields = ["Content-Type" : "application/x-www-form-urlencoded"]
        request.httpBody = form.composeBody(withParamaters: endpointParameters[command] ?? [], type: .Form)
        
        return HTTPpublisher.Decode(from: request, using: newJSONDecoder()) // Use the custom decoder that came provided with the generated model-files
    }
    
}
