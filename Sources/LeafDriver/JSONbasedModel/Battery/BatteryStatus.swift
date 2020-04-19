// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let batteryStatus = try BatteryStatus(json)

import Foundation

// MARK: - BatteryStatus
struct BatteryStatus: Codable {
    let batteryChargingStatus, batteryCapacity, batteryRemainingAmount, batteryRemainingAmountWH: String
    let batteryRemainingAmountkWH: String
    let soc: Soc

    enum CodingKeys: String, CodingKey {
        case batteryChargingStatus = "BatteryChargingStatus"
        case batteryCapacity = "BatteryCapacity"
        case batteryRemainingAmount = "BatteryRemainingAmount"
        case batteryRemainingAmountWH = "BatteryRemainingAmountWH"
        case batteryRemainingAmountkWH = "BatteryRemainingAmountkWH"
        case soc = "SOC"
    }
}

// MARK: BatteryStatus convenience initializers and mutators

extension BatteryStatus {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(BatteryStatus.self, from: data)
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
        batteryChargingStatus: String? = nil,
        batteryCapacity: String? = nil,
        batteryRemainingAmount: String? = nil,
        batteryRemainingAmountWH: String? = nil,
        batteryRemainingAmountkWH: String? = nil,
        soc: Soc? = nil
    ) -> BatteryStatus {
        return BatteryStatus(
            batteryChargingStatus: batteryChargingStatus ?? self.batteryChargingStatus,
            batteryCapacity: batteryCapacity ?? self.batteryCapacity,
            batteryRemainingAmount: batteryRemainingAmount ?? self.batteryRemainingAmount,
            batteryRemainingAmountWH: batteryRemainingAmountWH ?? self.batteryRemainingAmountWH,
            batteryRemainingAmountkWH: batteryRemainingAmountkWH ?? self.batteryRemainingAmountkWH,
            soc: soc ?? self.soc
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
