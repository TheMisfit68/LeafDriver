// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let session = try? newJSONDecoder().decode(Session.self, from: jsonData)

import Foundation

// MARK: - Session
struct Session: Codable {
    let status: Int
    let sessionId: String
    let vehicleInfoList: VehicleInfoList
    let vehicle: Vehicle
    let encAuthToken: String
    let customerInfo: CustomerInfo
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

// MARK: - CustomerInfo
struct CustomerInfo: Codable {
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
    let vehicleInfo: VehicleInfo

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
