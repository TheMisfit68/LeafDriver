// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let vehicleInfo = try VehicleInfo(json)

import Foundation

// MARK: - VehicleInfo
struct VehicleInfo: Codable {
    let vin, dcmid, simid, naviid: String
    let encryptednaviid, msn, lastVehicleLoginTime: String
    let userVehicleBoundTime: Date
    let lastdcmUseTime, nonaviFlg, carName, carImage: String

    enum CodingKeys: String, CodingKey {
        case vin = "VIN"
        case dcmid = "DCMID"
        case simid = "SIMID"
        case naviid = "NAVIID"
        case encryptednaviid = "EncryptedNAVIID"
        case msn = "MSN"
        case lastVehicleLoginTime = "LastVehicleLoginTime"
        case userVehicleBoundTime = "UserVehicleBoundTime"
        case lastdcmUseTime = "LastDCMUseTime"
        case nonaviFlg = "NonaviFlg"
        case carName = "CarName"
        case carImage = "CarImage"
    }
}

// MARK: VehicleInfo convenience initializers and mutators

extension VehicleInfo {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(VehicleInfo.self, from: data)
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
        vin: String? = nil,
        dcmid: String? = nil,
        simid: String? = nil,
        naviid: String? = nil,
        encryptednaviid: String? = nil,
        msn: String? = nil,
        lastVehicleLoginTime: String? = nil,
        userVehicleBoundTime: Date? = nil,
        lastdcmUseTime: String? = nil,
        nonaviFlg: String? = nil,
        carName: String? = nil,
        carImage: String? = nil
    ) -> VehicleInfo {
        return VehicleInfo(
            vin: vin ?? self.vin,
            dcmid: dcmid ?? self.dcmid,
            simid: simid ?? self.simid,
            naviid: naviid ?? self.naviid,
            encryptednaviid: encryptednaviid ?? self.encryptednaviid,
            msn: msn ?? self.msn,
            lastVehicleLoginTime: lastVehicleLoginTime ?? self.lastVehicleLoginTime,
            userVehicleBoundTime: userVehicleBoundTime ?? self.userVehicleBoundTime,
            lastdcmUseTime: lastdcmUseTime ?? self.lastdcmUseTime,
            nonaviFlg: nonaviFlg ?? self.nonaviFlg,
            carName: carName ?? self.carName,
            carImage: carImage ?? self.carImage
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
