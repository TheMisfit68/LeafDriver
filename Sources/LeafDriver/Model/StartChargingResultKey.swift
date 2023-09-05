// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let startChargingResultKey = try? JSONDecoder().decode(StartChargingResultKey.self, from: jsonData)

import Foundation

// MARK: - StartChargingResultKey
struct StartChargingResultKey: Codable {
    let status: Int
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
    }
}
