// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let batteryUpdateRespons = try? newJSONDecoder().decode(batteryUpdateRespons.self, from: jsonData)

import Foundation

// MARK: - BatteryUpdateResponse
struct BatteryUpdateResponse: Codable {
    let status: Int
    let responseFlag: String
    let operationResult: String
    let timeStamp: String
    let cruisingRangeAcOn: String
    let cruisingRangeAcOff: String
    let currentChargeLevel: String
    let chargeMode: String
    let pluginState: String
    let charging: String
    let chargeStatus: String
    let batteryDegradation: String
    let batteryCapacity: String
    let timeRequiredToFull: BatteryUpdateTimeRequiredToFull
    let timeRequiredToFull200: BatteryUpdateTimeRequiredToFull
    let timeRequiredToFull2006KW: BatteryUpdateTimeRequiredToFull

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case responseFlag = "responseFlag"
        case operationResult = "operationResult"
        case timeStamp = "timeStamp"
        case cruisingRangeAcOn = "cruisingRangeAcOn"
        case cruisingRangeAcOff = "cruisingRangeAcOff"
        case currentChargeLevel = "currentChargeLevel"
        case chargeMode = "chargeMode"
        case pluginState = "pluginState"
        case charging = "charging"
        case chargeStatus = "chargeStatus"
        case batteryDegradation = "batteryDegradation"
        case batteryCapacity = "batteryCapacity"
        case timeRequiredToFull = "timeRequiredToFull"
        case timeRequiredToFull200 = "timeRequiredToFull200"
        case timeRequiredToFull2006KW = "timeRequiredToFull200_6kW"
    }
}

// MARK: - BatteryUpdateTimeRequiredToFull
struct BatteryUpdateTimeRequiredToFull: Codable {
    let hours: String
    let minutes: String

    enum CodingKeys: String, CodingKey {
        case hours = "hours"
        case minutes = "minutes"
    }
}
