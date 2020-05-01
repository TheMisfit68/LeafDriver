// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let airCoOffRespons = try? newJSONDecoder().decode(airCoOffRespons.self, from: jsonData)

import Foundation

// MARK: - AirCoOffRespons
struct AirCoOffRespons: Codable {
    let status: Int
    let responseFlag: String
    let operationResult: String
    let acContinueTime: String
    let timeStamp: String
    let hvacStatus: String

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case responseFlag = "responseFlag"
        case operationResult = "operationResult"
        case acContinueTime = "acContinueTime"
        case timeStamp = "timeStamp"
        case hvacStatus = "hvacStatus"
    }
}
