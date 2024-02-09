// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let session = try? JSONDecoder().decode(Session.self, from: jsonData)

import Foundation

// MARK: - Session
struct Session: Codable {
    let status: Int
    let sessionId: String
    let vehicleInfoList: SessionVehicleInfoList
    let vehicle: SessionVehicle
    let encAuthToken: String
    let customerInfo: SessionCustomerInfo
    let userInfoRevisionNo: String
    let ngTapUpdatebtn: String
    let timeoutUpdateAnime: String
    let g1Lw: String
    let g1Li: String
    let g1Lt: String
    let g1Uw: String
    let g1Ui: String
    let g1Ut: String
    let g2Lw: String
    let g2Li: String
    let g2Lt: String
    let g2Uw: String
    let g2Ui: String
    let g2Ut: String
    let resultKey: String
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case sessionId = "sessionId"
        case vehicleInfoList = "VehicleInfoList"
        case vehicle = "vehicle"
        case encAuthToken = "EncAuthToken"
        case customerInfo = "CustomerInfo"
        case userInfoRevisionNo = "UserInfoRevisionNo"
        case ngTapUpdatebtn = "ngTapUpdatebtn"
        case timeoutUpdateAnime = "timeoutUpdateAnime"
        case g1Lw = "G1Lw"
        case g1Li = "G1Li"
        case g1Lt = "G1Lt"
        case g1Uw = "G1Uw"
        case g1Ui = "G1Ui"
        case g1Ut = "G1Ut"
        case g2Lw = "G2Lw"
        case g2Li = "G2Li"
        case g2Lt = "G2Lt"
        case g2Uw = "G2Uw"
        case g2Ui = "G2Ui"
        case g2Ut = "G2Ut"
        case resultKey = "resultKey"
    }
}

// MARK: - SessionCustomerInfo
struct SessionCustomerInfo: Codable {
    let userId: String
    let language: String
    let timezone: String
    let regionCode: String
    let ownerId: String
    let eMailAddress: String
    let nickname: String
    let country: String
    let vehicleImage: String
    let userVehicleBoundDurationSec: String
    let vehicleInfo: SessionCustomerInfoVehicleInfo
    
    enum CodingKeys: String, CodingKey {
        case userId = "UserId"
        case language = "Language"
        case timezone = "Timezone"
        case regionCode = "RegionCode"
        case ownerId = "OwnerId"
        case eMailAddress = "EMailAddress"
        case nickname = "Nickname"
        case country = "Country"
        case vehicleImage = "VehicleImage"
        case userVehicleBoundDurationSec = "UserVehicleBoundDurationSec"
        case vehicleInfo = "VehicleInfo"
    }
}

// MARK: - SessionCustomerInfoVehicleInfo
struct SessionCustomerInfoVehicleInfo: Codable {
    let vin: String
    let dcmid: String
    let simid: String
    let naviid: String
    let encryptedNAVIID: String
    let msn: String
    let lastVehicleLoginTime: String
    let userVehicleBoundTime: Date
    let lastDCMUseTime: String
    let nonaviFlg: String
    let carName: String
    let carImage: String
    
    enum CodingKeys: String, CodingKey {
        case vin = "VIN"
        case dcmid = "DCMID"
        case simid = "SIMID"
        case naviid = "NAVIID"
        case encryptedNAVIID = "EncryptedNAVIID"
        case msn = "MSN"
        case lastVehicleLoginTime = "LastVehicleLoginTime"
        case userVehicleBoundTime = "UserVehicleBoundTime"
        case lastDCMUseTime = "LastDCMUseTime"
        case nonaviFlg = "NonaviFlg"
        case carName = "CarName"
        case carImage = "CarImage"
    }
}

// MARK: - SessionVehicle
struct SessionVehicle: Codable {
    let profile: SessionProfile
    
    enum CodingKeys: String, CodingKey {
        case profile = "profile"
    }
}

// MARK: - SessionProfile
struct SessionProfile: Codable {
    let vin: String
    let gdcUserId: String
    let gdcPassword: String
    let encAuthToken: String
    let dcmId: String
    let nickname: String
    let modelyear: String
    
    enum CodingKeys: String, CodingKey {
        case vin = "vin"
        case gdcUserId = "gdcUserId"
        case gdcPassword = "gdcPassword"
        case encAuthToken = "encAuthToken"
        case dcmId = "dcmId"
        case nickname = "nickname"
        case modelyear = "modelyear"
    }
}

// MARK: - SessionVehicleInfoList
struct SessionVehicleInfoList: Codable {
    let vehicleInfo: [SessionVehicleInfoElement]
    let vehicleInfoListVehicleInfo: [SessionVehicleInfo]
    
    enum CodingKeys: String, CodingKey {
        case vehicleInfo = "VehicleInfo"
        case vehicleInfoListVehicleInfo = "vehicleInfo"
    }
}

// MARK: - SessionVehicleInfoElement
struct SessionVehicleInfoElement: Codable {
    let nickname: String
    let telematicsEnabled: String
    let vin: String
    
    enum CodingKeys: String, CodingKey {
        case nickname = "nickname"
        case telematicsEnabled = "telematicsEnabled"
        case vin = "vin"
    }
}

// MARK: - SessionVehicleInfo
struct SessionVehicleInfo: Codable {
    let nickname: String
    let telematicsEnabled: String
    let vin: String
    let customSessionid: String
    
    enum CodingKeys: String, CodingKey {
        case nickname = "nickname"
        case telematicsEnabled = "telematicsEnabled"
        case vin = "vin"
        case customSessionid = "custom_sessionid"
    }
}
