// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let airCoCommandStatus = try? newJSONDecoder().decode(airCoCommandStatus.self, from: jsonData)

import Foundation

// MARK: - AirCoCommandStatus
struct AirCoCommandStatus: Codable {
    let status: Int
    let responseFlag: String

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case responseFlag = "responseFlag"
    }
}


