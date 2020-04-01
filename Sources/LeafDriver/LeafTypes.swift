//
//  LeafTypes.swift
//  
//
//  Created by Jan Verrept on 24/03/2020.
//


public enum LeafCommand:String{
    
    case connect = "InitialApp_v2.php"
    case login = "UserLoginRequest.php"
    case batteryStatus = "BatteryStatusCheckRequest.php"
    case airCoOn = "ACRemoteRequest.php"
    case airCoOff = "ACRemoteOffRequest.php"
    
}


public enum LeafParameter:String{
    
    case initialAppStr = "initial_app_str"
    case customSessionID = "custom_sessionid"

    case userID = "UserId"
    case password = "Password"
    case key = "Key"
    
    case regionCode = "RegionCode"
    case language = "lg"
    
    case vin = "vin"
    case dcmid = "DCMID"
    case timeZone = "tz"
}
