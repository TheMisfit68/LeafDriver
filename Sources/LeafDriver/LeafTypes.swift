//
//  LeafTypes.swift
//  
//
//  Created by Jan Verrept on 24/03/2020.
//

import JVCocoa

public enum LeafCommand:String, StringRepresentableEnum{
    
    case connect = "InitialApp_v2.php"
    case login = "UserLoginRequest.php"
    
    case batteryStatus = "BatteryStatusRecordsRequest.php"
    case batteryUpdateRequest = "BatteryStatusCheckRequest.php"
    case BatteryUpdateRespons = "BatteryStatusCheckResultRequest.php"
    
    case airCoStatus = "RemoteACRecordsRequest.php"
    case airCoOnRequest = "ACRemoteRequest.php"
    case airCoOffRequest = "ACRemoteOffRequest.php"
    case airCoUpdate = "ACRemoteResult.php"
    
    case startCharging = ""
}

public enum LeafParameter:String, StringRepresentableEnum{
    
    case initialAppStr = "initial_app_str"
    case userID = "UserId"
    case clearPassword 
    case password = "Password"
    
    case customSessionID = "custom_sessionid"
    case regionCode = "RegionCode"
    case timeZone = "tz"
    case language = "lg"
    
    case vin = "VIN"
    case dcmid = "DCMID"

    case resultKey = "resultKey"
}

public enum Region:String, StringRepresentableEnum{
    
    case usa = "NNA"
    case europe = "NE"
    case canada = "NCI"
    case australia = "NMA"
    case japan = "NML"
    
}

public enum TimeZone:String, StringRepresentableEnum{
    case brussels = "Europe/Brussels"
}


public enum Language:String, StringRepresentableEnum{
    
    case american = "en-US"
    case dutch = "nl-NL"
    case flemish = "nl-BE"
    
}

