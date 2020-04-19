// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let batteryStatusRecords = try BatteryStatusRecords(json)

import Foundation

// MARK: - BatteryStatusRecords
struct BatteryStatusRecords: Codable {
    let operationResult, operationDateAndTime: String
    let batteryStatus: BatteryStatus
    let pluginState, cruisingRangeACOn, cruisingRangeACOff: String
    let timeRequiredToFull, timeRequiredToFull200, timeRequiredToFull2006KW: TimeRequiredToFull
    let notificationDateAndTime, targetDate: String

    enum CodingKeys: String, CodingKey {
        case operationResult = "OperationResult"
        case operationDateAndTime = "OperationDateAndTime"
        case batteryStatus = "BatteryStatus"
        case pluginState = "PluginState"
        case cruisingRangeACOn = "CruisingRangeAcOn"
        case cruisingRangeACOff = "CruisingRangeAcOff"
        case timeRequiredToFull = "TimeRequiredToFull"
        case timeRequiredToFull200 = "TimeRequiredToFull200"
        case timeRequiredToFull2006KW = "TimeRequiredToFull200_6kW"
        case notificationDateAndTime = "NotificationDateAndTime"
        case targetDate = "TargetDate"
    }
}

// MARK: BatteryStatusRecords convenience initializers and mutators

extension BatteryStatusRecords {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(BatteryStatusRecords.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        operationResult: String? = nil,
        operationDateAndTime: String? = nil,
        batteryStatus: BatteryStatus? = nil,
        pluginState: String? = nil,
        cruisingRangeACOn: String? = nil,
        cruisingRangeACOff: String? = nil,
        timeRequiredToFull: TimeRequiredToFull? = nil,
        timeRequiredToFull200: TimeRequiredToFull? = nil,
        timeRequiredToFull2006KW: TimeRequiredToFull? = nil,
        notificationDateAndTime: String? = nil,
        targetDate: String? = nil
    ) -> BatteryStatusRecords {
        return BatteryStatusRecords(
            operationResult: operationResult ?? self.operationResult,
            operationDateAndTime: operationDateAndTime ?? self.operationDateAndTime,
            batteryStatus: batteryStatus ?? self.batteryStatus,
            pluginState: pluginState ?? self.pluginState,
            cruisingRangeACOn: cruisingRangeACOn ?? self.cruisingRangeACOn,
            cruisingRangeACOff: cruisingRangeACOff ?? self.cruisingRangeACOff,
            timeRequiredToFull: timeRequiredToFull ?? self.timeRequiredToFull,
            timeRequiredToFull200: timeRequiredToFull200 ?? self.timeRequiredToFull200,
            timeRequiredToFull2006KW: timeRequiredToFull2006KW ?? self.timeRequiredToFull2006KW,
            notificationDateAndTime: notificationDateAndTime ?? self.notificationDateAndTime,
            targetDate: targetDate ?? self.targetDate
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
