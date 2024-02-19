//
//  BatteryChecker.swift
//
//
//  Created by Jan Verrept on 25/04/2020.
//

import Foundation
import JVSwift
import JVNetworking
import Combine
import OSLog

public class BatteryChecker{
	
	unowned let mainDriver: LeafDriver
	
	var restAPI:LeafDriver.LeafAPI
	
	// Models needed for a BatteryUpdate request
	var batteryUpdateResultKey:BatteryUpdateResultKey?
	var batteryUpdateStatus:BatteryUpdateStatus?
	var batteryUpdateResponse:BatteryUpdateResponse?
	
	// Model needed for a BatteryStatus request
	var batteryStatus:BatteryStatus?
	
	public var rangeRemaining:Int?{
		
		if  updateIsOutdated == false, let rangeString = batteryUpdateResponse?.cruisingRangeAcOff, let rangeInMeters = Float(rangeString){
			return Int(rangeInMeters/1000)
		}else if let rangeString = batteryStatus?.batteryStatusRecords.cruisingRangeAcOff, let rangeInMeters = Float(rangeString){
			return Int(rangeInMeters/1000)
		}else {
			return nil
		}
		
	}
	
	public var percentageRemaining:Int?{
		
		if updateIsOutdated == false,  let batteryDegradationString = batteryUpdateResponse?.batteryDegradation, let batteryCapacityString = batteryUpdateResponse?.batteryCapacity, let batteryDegradation = Float(batteryDegradationString), let batteryCapacity = Float(batteryCapacityString) {
			return Int( (batteryDegradation/batteryCapacity)*100.0 )
		}else if let percentageString = batteryStatus?.batteryStatusRecords.batteryStatus.soc.value, let percentage = Int(percentageString){
			return percentage
		}else {
			return nil
		}
		
	}
	
	public var connectionStatus:Bool?{
		
		if updateIsOutdated == false,  let pluginState = batteryUpdateResponse?.pluginState{
			return (pluginState == "CONNECTED")
		}else if let pluginState = batteryStatus?.batteryStatusRecords.pluginState{
			return (pluginState == "CHARGING")
		}else {
			return nil
		}
		
	}
	
	public var chargingStatus:Bool?{
		
		if updateIsOutdated == false,  let chargeMode = batteryUpdateResponse?.chargeMode{
			return (chargeMode == "CHARGING")
		}else if let batteryChargingStatus = batteryStatus?.batteryStatusRecords.batteryStatus.batteryChargingStatus{
			return (batteryChargingStatus == "CHARGING")
		}else {
			return nil
		}
		
	}
	
	public var updateTimeStamp:Date?{
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		guard let timeStampString = self.batteryUpdateResponse?.timeStamp else {return Date.distantPast}
		return formatter.date(from:timeStampString)
	}
	
	public var statusTargetDate:Date?{
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		guard let timeStampString = self.batteryStatus?.batteryStatusRecords.targetDate else {return Date.distantPast}
		return formatter.date(from: timeStampString)
	}
	
	private var previousUpdateRequest:Date = Date.distantPast
	private var updateIsOutdated:Bool{
		
		let updateIntervalInMinutes:Int = 30
		let now = Date()
		let someWhileAgo = Calendar.current.date(byAdding: .minute, value: -updateIntervalInMinutes, to: now) ?? previousUpdateRequest
		
		guard mainDriver.isIdle && (previousUpdateRequest < someWhileAgo) else {return false}
		
		guard let updateTimeStamp = self.updateTimeStamp, let statusTargetDate = self.statusTargetDate, (updateTimeStamp < statusTargetDate) else {
			sendBatteryUpdateRequest();
			previousUpdateRequest = now
			return true
		}
		
		return false
	}
	
	init(mainDriver:LeafDriver){
		self.mainDriver = mainDriver
		restAPI = RestAPI(baseURL: mainDriver.restAPI.baseURL)
	}
	
	// MARK: - BatteryUpdate
	
	/// Updates all values to the date and time of the last getBatteryStatus-request (should they seem outdated)
	/// Ensures that rangeRemaining or percentageRemaining are as up-to-date as possible when they are read
	public func sendBatteryUpdateRequest(){
		
		let commandMethodPair:LeafDriver.LeafCommandMethodPair = (command:.batteryUpdateRequest , method:self.sendBatteryUpdateRequest)
		guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue.enqueue(commandMethodPair); return}
		
		Task{
			do {
				
				self.batteryUpdateResultKey = try await restAPI.decode(method: .POST,
																	   command: LeafCommand.batteryUpdateRequest,
																	   includingBaseParameters: mainDriver.baseParameters,
																	   dateDecodingStrategy: .iso8601,
																	   timeout: 75)
				
				mainDriver.removeFromQueue(commandMethodPair)
				
				let nextCommandAndMethod:LeafDriver.LeafCommandMethodPair = (command:.batteryUpdateResponse,method:checkBatteryUpdateResponse)
				mainDriver.commandQueue.enqueue(nextCommandAndMethod)
				mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn)
				
			} catch let error {
				mainDriver.handleLeafAPIError(error, for: commandMethodPair )
			}
			mainDriver.runCommandQueue()
		}
		
	}
	
	private func checkBatteryUpdateResponse(){
		
		let commandMethodPair:LeafDriver.LeafCommandMethodPair = (command:.batteryUpdateResponse , method:self.checkBatteryUpdateResponse)
		guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue.enqueue(commandMethodPair); return}
		
		Task{
			do {
				let resultKeyParameters = ResultKeyParameters(resultKey: batteryUpdateResultKey?.resultKey ?? "")
				let responseData = try await restAPI.post(command: LeafCommand.batteryUpdateResponse, 
														  parameters:resultKeyParameters,
														  includingBaseParameters: mainDriver.baseParameters,
														  timeout: 75)
				
				guard responseData != nil else { return }
//				let decoder:JSONDecoder = JSONDecoder()
//				let batteryUpdateStatus = try decoder.decode(BatteryUpdateStatus.self, from: responseData!)
				self.batteryUpdateStatus = BatteryUpdateStatus(from:responseData!, dateDecodingStrategy: .iso8601)
				
				let updateReady:Bool = self.batteryUpdateStatus?.responseFlag == "1"
				guard updateReady else  {mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn); return}
//				let batteryUpdateResponse = try decoder.decode(BatteryUpdateResponse.self, from: responseData!)
				self.batteryUpdateResponse = BatteryUpdateResponse(from:responseData!, dateDecodingStrategy: .iso8601)
				
				mainDriver.removeFromQueue(commandMethodPair)
				mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn)
								
			} catch let error {
				mainDriver.handleLeafAPIError(error, for: commandMethodPair )
			}
			mainDriver.runCommandQueue()
		}
	}

	
	// MARK: - BatteryStatus
	/// Requests a brand new batterystatus for the current time
	public func getNewBatteryStatus(){
		
		let commandMethodPair:LeafDriver.LeafCommandMethodPair = (command:.batteryStatus , method:self.getNewBatteryStatus)
		guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue.enqueue(commandMethodPair); return}
		
		Task{
			do {
				
				self.batteryStatus = try await restAPI.decode(method: .POST,
															  command: LeafCommand.batteryStatus,
															  includingBaseParameters: mainDriver.baseParameters,
															  dateDecodingStrategy: .iso8601,
															  timeout: 75)
				
				mainDriver.removeFromQueue(commandMethodPair)
				mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn)
				
			} catch let error {
				mainDriver.handleLeafAPIError(error, for: commandMethodPair )
			}
			mainDriver.runCommandQueue()
		}
		
	}
	
	
}
