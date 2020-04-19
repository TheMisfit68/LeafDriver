// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let battery = try Battery(json)

import Foundation

// MARK: - Battery
struct Battery: Codable {
    let status: Int
    let voltLabel: VoltLabel
    let batteryStatusRecords: BatteryStatusRecords

    enum CodingKeys: String, CodingKey {
        case status
        case voltLabel = "VoltLabel"
        case batteryStatusRecords = "BatteryStatusRecords"
    }
}

// MARK: Battery convenience initializers and mutators

extension Battery {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Battery.self, from: data)
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
        status: Int? = nil,
        voltLabel: VoltLabel? = nil,
        batteryStatusRecords: BatteryStatusRecords? = nil
    ) -> Battery {
        return Battery(
            status: status ?? self.status,
            voltLabel: voltLabel ?? self.voltLabel,
            batteryStatusRecords: batteryStatusRecords ?? self.batteryStatusRecords
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
