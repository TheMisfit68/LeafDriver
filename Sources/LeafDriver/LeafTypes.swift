//
//  LeafTypes.swift
//
//
//  Created by Jan Verrept on 24/03/2020.
//

import JVSwift
import JVSwiftCore

public enum LeafCommand:String, StringRepresentableEnum{
	
	case connect = "InitialApp_v2.php"
	case login = "UserLoginRequest.php"
	
	case batteryStatus = "BatteryStatusRecordsRequest.php"
	case batteryUpdateRequest = "BatteryStatusCheckRequest.php"
	case batteryUpdateResponse = "BatteryStatusCheckResultRequest.php"
	
	case airCoStatus = "RemoteACRecordsRequest.php"
	case airCoOnRequest = "ACRemoteRequest.php"
	case airCoOffRequest = "ACRemoteOffRequest.php"
	case airCoUpdate = "ACRemoteResult.php"
	
	case startCharging = "BatteryRemoteChargingRequest.php"
	
}

public enum LeafParameter:String, StringRepresentableEnum{
    
    case initialAppStr = "initial_app_str"
    case userID = "UserId"
    case clearPassWord
    case encryptedPassWord = "Password"
    
    case customSessionID = "custom_sessionid"
    case regionCode = "RegionCode"
    case timeZone = "tz"
    case language = "lg"
    
    case vin = "VIN"
    case dcmid = "DCMID"
    
    case resultKey = "resultKey"
}

public enum Region:String, StringRepresentableEnum, CaseIterable, Identifiable{
    
    case usa = "NNA"
    case europe = "NE"
    case canada = "NCI"
    case australia = "NMA"
    case japan = "NML"
    
    public var id: String { rawValue }
}

public enum Language:String, StringRepresentableEnum, CaseIterable, Identifiable{
    
    case american = "en-US"
    case dutch = "nl-NL"
    case flemish = "nl-BE"
    
    public var id: String { rawValue }
}

public enum TimeZone:String, StringRepresentableEnum, CaseIterable, Identifiable{
    case brussels = "Europe/Brussels"
    
    public var id: String { rawValue }
}

// MARK: - CaseIterable

/// Used by pickers in SwiftUI
///to show a localized list String for all Enum cases
extension CaseIterable where Self == Region{
    
    public var id: Self { self }
    
    var localizedDescription: String {
        switch self {
        case .usa:
            return String(localized: "USA", bundle: .module)
        case .europe:
            return String(localized: "Europe", bundle: .module)
        case .canada:
            return String(localized: "Canada", bundle: .module)
        case .australia:
            return String(localized: "Australia", bundle: .module)
        case .japan:
            return String(localized: "Japan", bundle: .module)
        }
    }
    
}

extension CaseIterable where Self == Language{
    
    var localizedDescription: String {
        switch self {
        case .american:
            return String(localized: "American", bundle: .module)
        case .dutch:
            return String(localized: "Dutch", bundle: .module)
        case .flemish:
            return String(localized: "Flemish", bundle: .module)
        }
    }
}

extension CaseIterable where Self == TimeZone{

    var localizedDescription: String {
        switch self {
        case .brussels:
            return String(localized: "Brussels", bundle: .module)
            
        }
    }
}

