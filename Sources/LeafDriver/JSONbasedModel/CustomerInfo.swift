// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let customerInfo = try CustomerInfo(json)

import Foundation

// MARK: - CustomerInfo
struct CustomerInfo: Codable {
    let userID, language, timezone, regionCode: String
    let ownerID, eMailAddress, nickname, country: String
    let vehicleImage, userVehicleBoundDurationSEC: String
    let vehicleInfo: VehicleInfo

    enum CodingKeys: String, CodingKey {
        case userID = "UserId"
        case language = "Language"
        case timezone = "Timezone"
        case regionCode = "RegionCode"
        case ownerID = "OwnerId"
        case eMailAddress = "EMailAddress"
        case nickname = "Nickname"
        case country = "Country"
        case vehicleImage = "VehicleImage"
        case userVehicleBoundDurationSEC = "UserVehicleBoundDurationSec"
        case vehicleInfo = "VehicleInfo"
    }
}

// MARK: CustomerInfo convenience initializers and mutators

extension CustomerInfo {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CustomerInfo.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        userID: String? = nil,
        language: String? = nil,
        timezone: String? = nil,
        regionCode: String? = nil,
        ownerID: String? = nil,
        eMailAddress: String? = nil,
        nickname: String? = nil,
        country: String? = nil,
        vehicleImage: String? = nil,
        userVehicleBoundDurationSEC: String? = nil,
        vehicleInfo: VehicleInfo? = nil
    ) -> CustomerInfo {
        return CustomerInfo(
            userID: userID ?? self.userID,
            language: language ?? self.language,
            timezone: timezone ?? self.timezone,
            regionCode: regionCode ?? self.regionCode,
            ownerID: ownerID ?? self.ownerID,
            eMailAddress: eMailAddress ?? self.eMailAddress,
            nickname: nickname ?? self.nickname,
            country: country ?? self.country,
            vehicleImage: vehicleImage ?? self.vehicleImage,
            userVehicleBoundDurationSEC: userVehicleBoundDurationSEC ?? self.userVehicleBoundDurationSEC,
            vehicleInfo: vehicleInfo ?? self.vehicleInfo
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
