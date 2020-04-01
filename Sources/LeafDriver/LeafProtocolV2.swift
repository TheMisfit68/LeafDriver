//
//  LeafProtocolV2.swift
//  
//
//  Created by Jan Verrept on 28/03/2020.
//

import Foundation

public struct LeafProtocolV2:LeafProtocol{
    
    public var version:Int = 2

    public let baseURL: String = "https://gdcportalgw.its-mo.com/api_v190426_NE/gdc/"
    
    public var initialAppString:String = "9s5rfKVuMrT03RtzajWNcA"
            
    public let commands: [LeafCommand : [LeafParameter]] = [
        .connect : [.initialAppStr],
        .login : [.initialAppStr, .customSessionID, .regionCode, .password, .userID],
        .batteryStatus : [.initialAppStr, .regionCode, .language, .dcmid, .vin, .timeZone, .userID],
        .airCoOn : [],
        .airCoOff : []
    ]
    
    public init(){
    }
    
}
