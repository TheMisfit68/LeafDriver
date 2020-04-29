//
//  Decoding Publisher.swift
//  
//
//  Created by Jan Verrept on 13/04/2020.
//

//TODO: - Add this Class to JVCocoa

import Foundation
import Combine

@available(OSX 10.15, *)
class DecodingPublisher{
    
    // Publisher to decode received Json-String to a model object that conforms to Codable
    class func Publisher<T: Decodable>(from request:URLRequest, using decoder:JSONDecoder = JSONDecoder()) -> AnyPublisher<T?, Error> {
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { data, response -> T? in
                do {
                    guard let httpResponse = response as? HTTPURLResponse,
                        httpResponse.statusCode == 200 else {
                            return nil
                    }
                    return try decoder.decode(T.self, from: data) // Return an optional value
                } catch{
                    print("Decoding error: \(error).\n\(String(data: data, encoding:.utf8) ?? "") ")
                    return nil
                }
                
        }.receive(on: DispatchQueue.main)
            .eraseToAnyPublisher() // Make more generic
        
    }
    
    // Publisher to decode received Json-String to a directory of values
    class func Publisher(from request:URLRequest) -> AnyPublisher<[String: Any]?, Error>{
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> [String: Any]? in
                do {
                    return try JSONSerialization.jsonObject(with: result.data, options: []) as? [String : Any] //as? [String: Any]// Return an optional value
                } catch{
                    print("Decoding error: \(error).\n \(String(data: result.data, encoding:.utf8) ?? "") ")
                    return nil
                }
                
        }.receive(on: DispatchQueue.main)
            .eraseToAnyPublisher() // Make more generic
        
    }
    
}
