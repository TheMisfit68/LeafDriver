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
	
	private var parameters:[LeafParameter:String]{
		
		var currentParameters:[LeafParameter:String] = mainDriver.parameters
		var currentParameter:LeafParameter
		
		// ResultKey
		currentParameter = LeafParameter.resultKey
		if let currentValue = batteryUpdateResultKey?.resultKey{
			currentParameters[currentParameter] = currentValue
		}
		
		return currentParameters
	}
	
	init(mainDriver:LeafDriver){
		self.mainDriver = mainDriver
		restAPI = RestAPI<LeafCommand, LeafParameter>(baseURL: mainDriver.restAPI.baseURL, endpointParameters: mainDriver.restAPI.endpointParameters)
	}
	
	// MARK: - BatteryUpdate
	
	/// Updates all values to the date and time of the last getBatteryStatus-request (should they seem outdated)
	/// Ensures that rangeRemaining or percentageRemaining are as up-to-date as possible when they are read
	public func sendBatteryUpdateRequest(){
		
		let commandMethodPair:LeafDriver.LeafCommandMethodPair = (command:.batteryUpdateRequest , method:self.sendBatteryUpdateRequest)
		guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue.enqueue(commandMethodPair); return}
		
		Task{
			do {
				
				self.batteryUpdateResultKey = try await restAPI.decode(method: .POST, command: .batteryUpdateRequest, parameters: parameters)
				
				mainDriver.removeFromQueue(commandMethodPair)
				
				let nextCommandAndMethod:LeafDriver.LeafCommandMethodPair = (command:.batteryUpdateResponse,method:checkBatteryUpdateResponse)
				mainDriver.commandQueue.enqueue(nextCommandAndMethod)
				mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn)
				
			} catch let error as LeafDriver.LeafAPI.Error{
				mainDriver.handleLeafAPIError(error, for: commandMethodPair )
			}
			
		}
		
	}
	
	private func checkBatteryUpdateResponse(){
		
		let commandMethodPair:LeafDriver.LeafCommandMethodPair = (command:.batteryUpdateResponse , method:self.checkBatteryUpdateResponse)
		guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue.enqueue(commandMethodPair); return}
		
		Task{
			do {
				let responseData = try? await restAPI.post(command: .batteryUpdateResponse, parameters: parameters)
				guard responseData != nil else { return }
				let decoder:JSONDecoder = JSONDecoder()
				
				guard let batteryUpdateStatus = try? decoder.decode(BatteryUpdateStatus.self, from: responseData!) else { throw LeafDriver.LeafAPI.Error.decodingError}
				self.batteryUpdateStatus = batteryUpdateStatus
				let updateReady:Bool = self.batteryUpdateStatus?.responseFlag == "1"
				
				guard updateReady else  {mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn); return}
				guard let batteryUpdateResponse = try? decoder.decode(BatteryUpdateResponse.self, from: responseData!) else {throw LeafDriver.LeafAPI.Error.decodingError}
				self.batteryUpdateResponse = batteryUpdateResponse
				
				mainDriver.removeFromQueue(commandMethodPair)
				mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn)
								
			} catch let error as LeafDriver.LeafAPI.Error{
				mainDriver.handleLeafAPIError(error, for: commandMethodPair )
			}
			
		}
	}

	
	// MARK: - BatteryStatus
	/// Requests a brand new batterystatus for the current time
	public func getNewBatteryStatus(){
		
		let commandMethodPair:LeafDriver.LeafCommandMethodPair = (command:.batteryStatus , method:self.getNewBatteryStatus)
		guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue.enqueue(commandMethodPair); return}
		
		Task{
			do {
				
				self.batteryStatus = try await restAPI.decode(method: .POST, command: .batteryStatus, parameters: parameters)
				
				mainDriver.removeFromQueue(commandMethodPair)
				mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn)
				
			} catch let error as LeafDriver.LeafAPI.Error{
				mainDriver.handleLeafAPIError(error, for: commandMethodPair )
			}
			
		}
		
	}
	
	
}
