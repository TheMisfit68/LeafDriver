// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let airCoOnRespons = try? newJSONDecoder().decode(airCoOnRespons.self, from: jsonData)

import Foundation

// MARK: - AirCoOnRespons
struct AirCoOnRespons: Codable {
    let status: Int
    let responseFlag: String
    let operationResult: String
    let acContinueTime: String
    let cruisingRangeAcOn: String
    let cruisingRangeAcOff: String
    let timeStamp: String
    let hvacStatus: String

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case responseFlag = "responseFlag"
        case operationResult = "operationResult"
        case acContinueTime = "acContinueTime"
        case cruisingRangeAcOn = "cruisingRangeAcOn"
        case cruisingRangeAcOff = "cruisingRangeAcOff"
        case timeStamp = "timeStamp"
        case hvacStatus = "hvacStatus"
    }
}
