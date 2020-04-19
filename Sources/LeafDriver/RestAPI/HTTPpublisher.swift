//
//  HTTPpublisher.swift
//  
//
//  Created by Jan Verrept on 13/04/2020.
//

//TODO: - Add this Class to JVCocoa

import Foundation
import Combine

@available(OSX 10.15, *)
class HTTPpublisher:URLSession{
    
    class func Decode<T: Decodable>(from request:URLRequest, using decoder:JSONDecoder = JSONDecoder()) -> AnyPublisher<T?, Error> {
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> T? in
                do {
                    return try decoder.decode(T.self, from: result.data) // Return an optional value
                } catch{
                    print("Decoding error: \(error).")
                    return nil
                }
                
        }.receive(on: DispatchQueue.main)
            .eraseToAnyPublisher() // Make more generic
    }
    
}


