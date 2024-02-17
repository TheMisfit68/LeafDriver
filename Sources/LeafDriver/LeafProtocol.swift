//
//  LeafProtocol.swift
//  
//
//  Created by Jan Verrept on 26/03/2020.
//

import Foundation
import JVNetworking

public protocol LeafProtocol{
    
    var version:Int {get}
    
    var baseURL:String {get}
    
    var initialAppString:String {get}
        
}
