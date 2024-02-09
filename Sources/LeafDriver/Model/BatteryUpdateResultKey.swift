// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let batteryUpdateResultKey = try? JSONDecoder().decode(batteryUpdateResultKey.self, from: jsonData)

import Foundation

// MARK: - BatteryUpdateResultKey
struct BatteryUpdateResultKey: Codable {
    let status: Int
    let userId: String
    let vin: String
    let resultKey: String

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case userId = "userId"
        case vin = "vin"
        case resultKey = "resultKey"
    }
}
