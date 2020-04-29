// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let batteryUpdate = try? newJSONDecoder().decode(batteryUpdate.self, from: jsonData)

import Foundation

// MARK: - batteryUpdate
struct BatteryUpdateStatus: Codable {
    let status: Int
    let responseFlag: String

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case responseFlag = "responseFlag"
    }
}


