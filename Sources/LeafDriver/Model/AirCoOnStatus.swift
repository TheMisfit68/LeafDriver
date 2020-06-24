// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let airCoOnStatus = try? newJSONDecoder().decode(airCoOnStatus.self, from: jsonData)

import Foundation

// MARK: - AirCoOnStatus
struct AirCoOnStatus: Codable {
    let status: Int
    let responseFlag: String

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case responseFlag = "responseFlag"
    }
}


