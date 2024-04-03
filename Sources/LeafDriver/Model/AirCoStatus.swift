// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let airCoStatus = try? JSONDecoder().decode(AirCoStatus.self, from: jsonData)

import Foundation

// MARK: - AirCoStatus
struct AirCoStatus: Codable {
	let status: Int
	let remoteAcRecords: RemoteAcRecords
	
	enum CodingKeys: String, CodingKey {
		case status = "status"
		case remoteAcRecords = "RemoteACRecords"
	}
}

// MARK: - RemoteAcRecords
struct RemoteAcRecords: Codable {
	let operationResult: String
	let operationDateAndTime: String
	let remoteAcOperation: String
	let acStartStopDateAndTime: String
	let cruisingRangeAcOn: String
	let cruisingRangeAcOff: String
	let acStartStopUrl: String
	let pluginState: String
	let acDurationBatterySec: String
	let acDurationPluggedSec: String
	let preAcUnit: String
	let preAcTemp: String
	let incTemp: String
	
	enum CodingKeys: String, CodingKey {
		case operationResult = "OperationResult"
		case operationDateAndTime = "OperationDateAndTime"
		case remoteAcOperation = "RemoteACOperation"
		case acStartStopDateAndTime = "ACStartStopDateAndTime"
		case cruisingRangeAcOn = "CruisingRangeAcOn"
		case cruisingRangeAcOff = "CruisingRangeAcOff"
		case acStartStopUrl = "ACStartStopURL"
		case pluginState = "PluginState"
		case acDurationBatterySec = "ACDurationBatterySec"
		case acDurationPluggedSec = "ACDurationPluggedSec"
		case preAcUnit = "PreAC_unit"
		case preAcTemp = "PreAC_temp"
		case incTemp = "Inc_temp"
	}
}
