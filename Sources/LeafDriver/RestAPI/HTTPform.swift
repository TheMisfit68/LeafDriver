//
//  File.swift
//  
//
//  Created by Jan Verrept on 19/04/2020.
//

import Foundation

//TODO: - Add this Class to JVCocoa

struct HTTPForm<P:StringRepresentableEnum>{
    
    public enum HTTPbodyType{
        case Json
        case Form
        case Custom
    }
    
    public var parameters:[P:String]
    
    public mutating func composeBody(withParamaters parametersToInclude:[P], type:HTTPbodyType = .Json)->Data?{
        
        let  filteredParameters = parameters.filter { (parameterName, parameterValue) in parametersToInclude.contains(parameterName)}
        let  stringRepresentations = filteredParameters.map {(parameterName, parameterValue) in (parameterName.stringValue, parameterValue)}
        
        switch type {
        case .Json:
            return try? JSONSerialization.data(withJSONObject: stringRepresentations, options: .prettyPrinted)
        case .Form:
            let parametersAndValues = stringRepresentations.map {parameterName, parameterValue in return "\(parameterName)=\(parameterValue)" }
            let paramaterString = parametersAndValues.joined(separator: "&")
            return paramaterString.data(using: .utf8)
        case .Custom:
            let parametersAndValues = stringRepresentations.map {parameterName, parameterValue in "\(parameterName)=\(parameterValue)" }
            let paramaterString = parametersAndValues.joined(separator: "\n")
            return paramaterString.data(using: .utf8)
        }
    }
    
    public func encode(_ parameter:String)->String{
        
        var encodedParameter = parameter
        encodedParameter = encodedParameter.replacingOccurrences(of: "/", with: "%2F")
        encodedParameter = encodedParameter.replacingOccurrences(of: "+", with: "%2B")
        encodedParameter = encodedParameter.replacingOccurrences(of: "=", with: "%3D")
        
        return encodedParameter
    }
    
    
}
