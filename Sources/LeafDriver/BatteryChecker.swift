//
//  BatteryChecker.swift
//
//
//  Created by Jan Verrept on 25/04/2020.
//

import Foundation
import JVCocoa
import Combine
import OSLog

@available(OSX 12.0, *)
public class BatteryChecker{
    
    unowned let mainDriver: LeafDriver
    var restAPI:LeafDriver.LeafAPI
    
    var batteryUpdateResultKey:BatteryUpdateResultKey?
    var batteryUpdateresponseBatteryUpdateresponse
    var batteryStatus:BatteryStatus?
    
    public var rangeRemaining:Int?{
        
        if  updateIsOutdated == false, let rangeString = batteryUpdateresponse.cruisingRangeAcOff, let rangeInMeters = Int(rangeString){
            return rangeInMeters/1000
        }else if let rangeString = batteryStatus?.batteryStatusRecords.cruisingRangeAcOff, let rangeInMeters = Int(rangeString){
            return rangeInMeters/1000
        }else {
            return nil
        }
        
    }
    
    public var percentageRemaining:Int?{
        
        if updateIsOutdated == false,  let batteryDegradationString = batteryUpdateresponse.batteryDegradation, let batteryCapacityString = batteryUpdateresponse.batteryCapacity, let batteryDegradation = Int(batteryDegradationString), let batteryCapacity = Int(batteryCapacityString) {
            return (batteryDegradation / batteryCapacity)*100
        }else if let percentageString = batteryStatus?.batteryStatusRecords.batteryStatus.soc.value, let percentage = Int(percentageString){
            return percentage
        }else {
            return nil
        }
    }
    
    private var updateIsOutdated:Bool{
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/mm/dd HH:mm"
        guard let updateTimeStamp = formatter.date(from: batteryUpdateresponse.timeStamp ?? "") else {self.sendBatteryUpdateRequest(); return true}
        
        if let statusTargetDate = formatter.date(from: batteryStatus?.batteryStatusRecords.targetDate ?? ""), (updateTimeStamp < statusTargetDate){
            self.sendBatteryUpdateRequest()
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
    
    public func sendBatteryUpdateRequest(){
        
        let thisCommand:LeafCommand = .batteryUpdateRequest
        let thisMethod = self.sendBatteryUpdateRequest
        
        guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue[thisCommand] = thisMethod; return}
        
        Task{
            do {
                self.batteryUpdateResultKey = try await restAPI.decode(method: .POST, command: thisCommand, parameters: parameters)
                
                mainDriver.commandQueue.removeValue(forKey: thisCommand)
                mainDriver.commandQueue[.batteryUpdateresponse = self.checkBatteryUpdateresponse                mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn)
                
            } catch LeafDriver.LeafAPI.Error.statusError{
                mainDriver.commandQueue[thisCommand] = thisMethod
                mainDriver.connectionState = min(mainDriver.connectionState, .disconnected)
            }	catch LeafDriver.LeafAPI.Error.decodingError{
                mainDriver.commandQueue[thisCommand] = thisMethod
                mainDriver.connectionState = min(mainDriver.connectionState, .connected)
            }
        }
        
        
    }
    
    private func checkBatteryUpdateresponse){
        
        let thisCommand:LeafCommand = .batteryUpdateresponse        let thisMethod = self.checkBatteryUpdateresponse        let decoder:JSONDecoder = newJSONDecoder()
        
        guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue[thisCommand] = thisMethod; return}
        
        
        Task{
            do {
                guard let data = try? await restAPI.post(command: thisCommand, parameters: parameters) else { self.mainDriver.commandQueue[thisCommand] = thisMethod; return}
                
                guard let batteryUpdateStatus = try? decoder.decode(BatteryUpdateStatus.self, from: data) else { throw LeafDriver.LeafAPI.Error.decodingError }
                guard (batteryUpdateStatus.responseFlag == "1") else { self.mainDriver.commandQueue[thisCommand] = thisMethod; return}
                guard let batteryUpdateresponse= try? decoder.decode(BatteryUpdateresponseself, from: data) else { throw LeafDriver.LeafAPI.Error.decodingError}
                
                self.batteryUpdateresponse= batteryUpdateresponse                
                mainDriver.commandQueue.removeValue(forKey: thisCommand)
                mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn)
                
            } catch LeafDriver.LeafAPI.Error.statusError{
                mainDriver.commandQueue[thisCommand] = thisMethod
                mainDriver.connectionState = min(mainDriver.connectionState, .disconnected)
            }	catch LeafDriver.LeafAPI.Error.decodingError{
                mainDriver.commandQueue[thisCommand] = thisMethod
                mainDriver.connectionState = min(mainDriver.connectionState, .connected)
            }
            
        }
        
    }
    
    public func getBatteryStatus(){
        
        let thisCommand:LeafCommand = .batteryStatus
        let thisMethod = self.getBatteryStatus
        
        guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue[thisCommand] = thisMethod; return}
        
        
        Task{
            do {
                self.batteryStatus = try await restAPI.decode(method: .POST, command: thisCommand, parameters: parameters)
                
                mainDriver.commandQueue.removeValue(forKey: thisCommand)
                mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn)
                
            } catch LeafDriver.LeafAPI.Error.statusError{
                mainDriver.commandQueue[thisCommand] = thisMethod
                mainDriver.connectionState = min(mainDriver.connectionState, .disconnected)
            }    catch LeafDriver.LeafAPI.Error.decodingError{
                mainDriver.commandQueue[thisCommand] = thisMethod
                mainDriver.connectionState = min(mainDriver.connectionState, .connected)
            }
        }
        
    }
    
    
}
