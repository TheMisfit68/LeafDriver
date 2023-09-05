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
    
    var batteryStatus:BatteryStatus?
    
    public var rangeRemaining:Int?{
        guard let rangeInMeters = Int(batteryStatus?.batteryStatusRecords.cruisingRangeAcOff ?? "") else {return nil}
        return rangeInMeters/1000
    }
    public var percentageRemaining:Int?{
        guard let percentage = Int(batteryStatus?.batteryStatusRecords.batteryStatus.soc.value ?? "") else {return nil}
        return percentage
    }
    
    var batteryUpdateResultKey:BatteryUpdateResultKey?
    var batteryUpdateRespons:BatteryUpdateRespons?{
        didSet{
            if batteryUpdateRespons?.responseFlag == "1"{
                self.batteryStatus?.batteryStatusRecords.cruisingRangeAcOff = batteryUpdateRespons!.cruisingRangeAcOff
                self.batteryStatus?.batteryStatusRecords.cruisingRangeAcOn  = batteryUpdateRespons!.cruisingRangeAcOn
                self.batteryStatus?.batteryStatusRecords.timeRequiredToFull2006KW?.hourRequiredToFull = batteryUpdateRespons!.timeRequiredToFull2006KW.hours
                self.batteryStatus?.batteryStatusRecords.timeRequiredToFull2006KW?.minutesRequiredToFull = batteryUpdateRespons!.timeRequiredToFull2006KW.minutes
            }
        }
    }
    
    var parameters:[LeafParameter:String]{
        
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
    
    
    public func getBatteryStatus(){
        
        let thisCommand:LeafCommand = .batteryStatus
        let thisMethod = self.getBatteryStatus
        
        guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue[thisCommand] = thisMethod; return}
        
        
        Task{
            do {
                self.batteryStatus = try await restAPI.decode(method: .POST, command: thisCommand, parameters: parameters)
                
                mainDriver.commandQueue.removeValue(forKey: thisCommand)
                mainDriver.commandQueue[.batteryUpdateRequest] = self.sendBatteryUpdateRequest
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
    
    
    private func sendBatteryUpdateRequest(){
        
        let thisCommand:LeafCommand = .batteryUpdateRequest
        let thisMethod = self.sendBatteryUpdateRequest
        
        guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue[thisCommand] = thisMethod; return}
        
        Task{
            do {
                self.batteryUpdateResultKey = try await restAPI.decode(method: .POST, command: thisCommand, parameters: parameters)
                
                mainDriver.commandQueue.removeValue(forKey: thisCommand)
                mainDriver.commandQueue[.batteryUpdateRespons] = self.checkBatteryUpdateRespons
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
    
    private func checkBatteryUpdateRespons(){
                
        let thisCommand:LeafCommand = .batteryUpdateRespons
        let thisMethod = self.checkBatteryUpdateRespons
        let decoder:JSONDecoder = newJSONDecoder()

        guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue[thisCommand] = thisMethod; return}
        
        
        Task{
            do {
                guard let data = try? await restAPI.post(command: thisCommand, parameters: parameters) else { self.mainDriver.commandQueue[thisCommand] = thisMethod; return}
                let dataString = String(decoding: data, as: UTF8.self)
                let logger = Logger(subsystem: "be.oneclick.Leafdriver", category: "BatteryChecker")
                logger.info("↩️\tReceived data for \(thisCommand.stringValue, privacy: .public):\n\(dataString, privacy: .public)")
                
                guard let batteryUpdateStatus = try? decoder.decode(BatteryUpdateStatus.self, from: data) else { throw LeafDriver.LeafAPI.Error.decodingError }
                guard (batteryUpdateStatus.responseFlag == "1") else { self.mainDriver.commandQueue[thisCommand] = thisMethod; return}
                guard let batteryUpdateRespons = try? decoder.decode(BatteryUpdateRespons.self, from: data) else { throw LeafDriver.LeafAPI.Error.decodingError}
                
                self.batteryUpdateRespons = batteryUpdateRespons
                
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
    
    
}
