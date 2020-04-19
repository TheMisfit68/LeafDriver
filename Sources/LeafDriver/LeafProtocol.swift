//
//  LeafProtocol.swift
//  
//
//  Created by Jan Verrept on 26/03/2020.
//

import Foundation

public protocol LeafProtocol{
    
    var version:Int {get}
    
    var baseURL:String {get}
    
    var initialAppString:String {get}
    
    var requiredCommandParameters:[LeafCommand : [LeafParameter]] {get}
    

}
