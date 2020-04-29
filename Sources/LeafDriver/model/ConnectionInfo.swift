// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let connectionInfo = try? newJSONDecoder().decode(ConnectionInfo.self, from: jsonData)

import Foundation

// MARK: - ConnectionInfo
struct ConnectionInfo: Codable {
    let status: Int
    let message: String
    let baseprm: String

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
        case baseprm = "baseprm"
    }
}
