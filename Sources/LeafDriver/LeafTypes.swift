//
//  LeafTypes.swift
//  
//
//  Created by Jan Verrept on 24/03/2020.
//

public protocol StringRepresentable { var stringValue:String{get} }

public extension StringRepresentable where Self:RawRepresentable, Self.RawValue == String{
     var stringValue:String{
        return self.rawValue as String
    }
}
public extension StringRepresentable where Self:StringProtocol {
     var stringValue:String{
        return String(describing: self)
    }
}
public protocol StringRepresentableEnum: StringRepresentable & RawRepresentable & Hashable {}

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

