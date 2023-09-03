//
//  BatteryChecker.swift
//
//
//  Created by Jan Verrept on 25/04/2020.
//

import Foundation
import JVCocoa
import Combine
import SiriDriver

@available(OSX 12.0, *)
public class BatteryChecker{
    
    unowned let mainDriver: LeafDriver
    unowned let siriDriver: SiriDriver
    
    var restAPI:LeafDriver.LeafAPI
    
    var batteryStatusPublisher:AnyPublisher<BatteryStatus?, Error>!
    var batteryStatusReceiver:Cancellable!
    
    var batteryUpdateResultKeyPublisher:AnyPublisher<BatteryUpdateResultKey?, Error>!
    var batteryUpdateResultKeyReceiver:Cancellable!
    var batteryUpdateStatusPublisher:AnyPublisher<BatteryUpdateStatus?, Error>!
    var batteryUpdateStatusReceiver:Cancellable!
    var batteryUpdateResponsPublisher:AnyPublisher<BatteryUpdateRespons?, Error>!
    var batteryUpdateResponsReceiver:Cancellable!
    
    var batteryStatus:BatteryStatus?{
        didSet{
            if let stats = batteryStatus?.batteryStatusRecords, let rangeInMeters = Int(stats.cruisingRangeAcOff){
                let percentage = stats.batteryStatus.soc.value
                siriDriver.speak(text: "Nog \(percentage) percent of \(rangeInMeters/1000) kilometer")
            }
        }
    }
    var batteryUpdateResultKey:BatteryUpdateResultKey?
    
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
        self.siriDriver = mainDriver.siriDriver
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
                mainDriver.commandQueue[thisCommand] = self.requestbatteryUpdate
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
    
    
    private func requestbatteryUpdate(){
        
        let thisCommand:LeafCommand = .batteryUpdateRequest
        let thisMethod = self.requestbatteryUpdate
        
        guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue[thisCommand] = thisMethod; return}
        
        Task{
            do {
                self.batteryUpdateResultKey = try await restAPI.decode(method: .POST, command: thisCommand, parameters: parameters)
                
                mainDriver.commandQueue.removeValue(forKey: thisCommand)
                mainDriver.commandQueue[thisCommand] = self.checkCommandCompletion
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
    
    private func checkCommandCompletion(){
        
        let thisCommand:LeafCommand = .batteryUpdateRespons
        let thisMethod = self.checkCommandCompletion
        
        guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue[thisCommand] = thisMethod; return}
        
        
        Task{
            do {
                let batteryUpdateRespons:BatteryUpdateRespons? = try await restAPI.decode(method: .POST, command: thisCommand, parameters: parameters)
                guard batteryUpdateRespons?.responseFlag == "1" else { self.mainDriver.commandQueue[thisCommand] = thisMethod; return}
                
                mainDriver.commandQueue.removeValue(forKey: thisCommand)
                mainDriver.commandQueue[thisCommand] = self.parseBatteryUpdate
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
    
    
    private func parseBatteryUpdate(){
        
        let thisCommand:LeafCommand = .batteryUpdateRespons
        let thisMethod = self.parseBatteryUpdate
        
        guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue[thisCommand] = thisMethod; return}
        
        
        Task{
            do {
                let batteryUpdateRespons:BatteryUpdateRespons? = try await restAPI.decode(method: .POST, command: thisCommand, parameters: parameters)
                guard batteryUpdateRespons?.responseFlag == "1" else { self.mainDriver.commandQueue[thisCommand] = thisMethod; return}
                
                self.batteryStatus?.batteryStatusRecords.cruisingRangeAcOff = batteryUpdateRespons!.cruisingRangeAcOff
                self.batteryStatus?.batteryStatusRecords.cruisingRangeAcOn  = batteryUpdateRespons!.cruisingRangeAcOn
                self.batteryStatus?.batteryStatusRecords.timeRequiredToFull2006KW.hourRequiredToFull = batteryUpdateRespons!.timeRequiredToFull2006KW.hours
                self.batteryStatus?.batteryStatusRecords.timeRequiredToFull2006KW.minutesRequiredToFull = batteryUpdateRespons!.timeRequiredToFull2006KW.minutes
                
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
