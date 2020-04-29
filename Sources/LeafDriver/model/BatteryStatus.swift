// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let batteryStatus = try? newJSONDecoder().decode(BatteryStatus.self, from: jsonData)

import Foundation

// MARK: - BatteryStatus
struct BatteryStatus: Codable {
    let status: Int
    let voltLabel: VoltLabel
    var batteryStatusRecords: BatteryStatusRecords

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case voltLabel = "VoltLabel"
        case batteryStatusRecords = "BatteryStatusRecords"
    }
}

// MARK: - BatteryStatusRecords
struct BatteryStatusRecords: Codable {
    let operationResult: String
    let operationDateAndTime: String
    let batteryStatus: BatteryStatusClass
    let pluginState: String
    var cruisingRangeAcOn: String
    var cruisingRangeAcOff: String
    let timeRequiredToFull: TimeRequiredToFull
    let timeRequiredToFull200: TimeRequiredToFull
    var timeRequiredToFull2006KW: TimeRequiredToFull
    let notificationDateAndTime: String
    let targetDate: String

    enum CodingKeys: String, CodingKey {
        case operationResult = "OperationResult"
        case operationDateAndTime = "OperationDateAndTime"
        case batteryStatus = "BatteryStatus"
        case pluginState = "PluginState"
        case cruisingRangeAcOn = "CruisingRangeAcOn"
        case cruisingRangeAcOff = "CruisingRangeAcOff"
        case timeRequiredToFull = "TimeRequiredToFull"
        case timeRequiredToFull200 = "TimeRequiredToFull200"
        case timeRequiredToFull2006KW = "TimeRequiredToFull200_6kW"
        case notificationDateAndTime = "NotificationDateAndTime"
        case targetDate = "TargetDate"
    }
}

// MARK: - BatteryStatusClass
struct BatteryStatusClass: Codable {
    let batteryChargingStatus: String
    let batteryCapacity: String
    let batteryRemainingAmount: String
    let batteryRemainingAmountWh: String
    let batteryRemainingAmountkWh: String
    let soc: Soc

    enum CodingKeys: String, CodingKey {
        case batteryChargingStatus = "BatteryChargingStatus"
        case batteryCapacity = "BatteryCapacity"
        case batteryRemainingAmount = "BatteryRemainingAmount"
        case batteryRemainingAmountWh = "BatteryRemainingAmountWH"
        case batteryRemainingAmountkWh = "BatteryRemainingAmountkWH"
        case soc = "SOC"
    }
}

// MARK: - Soc
struct Soc: Codable {
    let value: String

    enum CodingKeys: String, CodingKey {
        case value = "Value"
    }
}

// MARK: - TimeRequiredToFull
struct TimeRequiredToFull: Codable {
    var hourRequiredToFull: String
    var minutesRequiredToFull: String

    enum CodingKeys: String, CodingKey {
        case hourRequiredToFull = "HourRequiredToFull"
        case minutesRequiredToFull = "MinutesRequiredToFull"
    }
}

// MARK: - VoltLabel
struct VoltLabel: Codable {
    let highVolt: String
    let lowVolt: String

    enum CodingKeys: String, CodingKey {
        case highVolt = "HighVolt"
        case lowVolt = "LowVolt"
    }
}
