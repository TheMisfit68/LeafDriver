//
//  LeafProtocolV2.swift
//  
//
//  Created by Jan Verrept on 28/03/2020.
//

import Foundation
import JVNetworking

/// write alle struct names in uppercase
public struct LeafProtocolV2:LeafProtocol{
	
	public init(){}
    
    public var version:Int = 2
    
//	Stopped working May 2024
//    public let baseURL: String = "https://gdcportalgw.its-mo.com/api_v210707_NE/gdc/"
	
	public let baseURL: String = "https://gdcportalgw.its-mo.com/api_v230317_NE/gdc/"

    public var initialAppString:String = "9s5rfKVuMrT03RtzajWNcA"
    
}


struct ConnectParameters: HTTPFormEncodable {
	var initialAppStr: String
	
	enum CodingKeys: String, CodingKey {
		case initialAppStr = "initial_app_str"
	}
}

struct LoginParameters: HTTPFormEncodable {
	var initialAppStr: String
	var userID: String
	var encryptedPassWord: String
	var regionCode: String
	var timeZone: String
	var language: String
	
	enum CodingKeys: String, CodingKey {
		case initialAppStr = "initial_app_str"
		case userID = "UserId"
		case encryptedPassWord = "Password"
		case regionCode = "RegionCode"
		case timeZone = "tz"
		case language = "lg"
	}
	
}

struct BaseParameters: HTTPFormEncodable {
	var regionCode: String
	var timeZone: String
	var language: String
	var customSessionID: String
	var vin: String
	var dcmid: String
	
	enum CodingKeys: String, CodingKey {
		case regionCode = "RegionCode"
		case timeZone = "tz"
		case language = "lg"
		case customSessionID = "custom_sessionid"
		case vin = "VIN"
		case dcmid = "DCMID"
	}
}

struct ResultKeyParameters: HTTPFormEncodable {
	var resultKey: String
	
	enum CodingKeys: String, CodingKey {
		case resultKey = "resultKey"
	}
}
