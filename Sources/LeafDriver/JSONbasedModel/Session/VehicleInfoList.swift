// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let vehicleInfoList = try VehicleInfoList(json)

import Foundation

// MARK: - VehicleInfoList
struct VehicleInfoList: Codable {
    let vehicleInfo, vehicleInfoListVehicleInfo: [VehicleInfoElement]

    enum CodingKeys: String, CodingKey {
        case vehicleInfo = "VehicleInfo"
        case vehicleInfoListVehicleInfo = "vehicleInfo"
    }
}

// MARK: VehicleInfoList convenience initializers and mutators

extension VehicleInfoList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(VehicleInfoList.self, from: data)
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
        vehicleInfo: [VehicleInfoElement]? = nil,
        vehicleInfoListVehicleInfo: [VehicleInfoElement]? = nil
    ) -> VehicleInfoList {
        return VehicleInfoList(
            vehicleInfo: vehicleInfo ?? self.vehicleInfo,
            vehicleInfoListVehicleInfo: vehicleInfoListVehicleInfo ?? self.vehicleInfoListVehicleInfo
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
