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
    
    public let requiredCommandParameters: [LeafCommand : [LeafParameter]] = [
        
        .connect : [.initialAppStr],
        .login :   [.initialAppStr, .userID, .password, .regionCode, .timeZone, .language],
        
        .batteryStatus : [.regionCode, .timeZone, .language, .customSessionID, .vin, .dcmid],
        .batteryUpdateRequest : [.regionCode, .timeZone, .language, .customSessionID, .vin, .dcmid],
        .BatteryUpdateRespons : [.regionCode, .timeZone, .language, .customSessionID, .vin, .dcmid, .resultKey],
        
        .airCoStatus :  [.regionCode, .timeZone, .language, .customSessionID, .vin, .dcmid],
        .airCoOnRequest :      [.regionCode, .timeZone, .language, .customSessionID, .vin, .dcmid],
        .airCoOffRequest :     [.regionCode, .timeZone, .language, .customSessionID, .vin, .dcmid],
        .airCoUpdate :  [.regionCode, .timeZone, .language, .customSessionID, .vin, .dcmid, .resultKey],
    ]
    
    public init(){
    }
    
}
