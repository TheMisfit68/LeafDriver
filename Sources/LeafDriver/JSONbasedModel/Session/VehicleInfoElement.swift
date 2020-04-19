// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let vehicleInfoElement = try VehicleInfoElement(json)

import Foundation

// MARK: - VehicleInfoElement
struct VehicleInfoElement: Codable {
    let nickname, telematicsEnabled, vin: String
    let customSessionid: String?

    enum CodingKeys: String, CodingKey {
        case nickname, telematicsEnabled, vin
        case customSessionid = "custom_sessionid"
    }
}

// MARK: VehicleInfoElement convenience initializers and mutators

extension VehicleInfoElement {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(VehicleInfoElement.self, from: data)
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
        nickname: String? = nil,
        telematicsEnabled: String? = nil,
        vin: String? = nil,
        customSessionid: String?? = nil
    ) -> VehicleInfoElement {
        return VehicleInfoElement(
            nickname: nickname ?? self.nickname,
            telematicsEnabled: telematicsEnabled ?? self.telematicsEnabled,
            vin: vin ?? self.vin,
            customSessionid: customSessionid ?? self.customSessionid
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
