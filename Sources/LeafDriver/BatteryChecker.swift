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

@available(OSX 10.15, *)
public class BatteryChecker{
    
    unowned let mainDriver: LeafDriver
    unowned let siriDriver: SiriDriver
    
    var restAPI:RestAPI<LeafCommand, LeafParameter>
    
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
        if mainDriver.connectionState == .loggedIn{
            
            batteryStatusPublisher = restAPI.publish(method:.POST,command: thisCommand, parameters: parameters)
            
            batteryStatusReceiver = batteryStatusPublisher
                .sink(receiveCompletion: {completion in
                    self.mainDriver.handle(completion: completion, of: thisCommand, recalOnFailure: thisMethod, callwhenSucceeded: self.requestbatteryUpdate)
                },receiveValue: {value in
                    if let batteryStatus = value{
                        self.batteryStatus = batteryStatus
                    }
                }
            )
        }else{
            mainDriver.commandQueue[thisCommand] = thisMethod
        }
        
    }
    
    private func requestbatteryUpdate(){
        
        let thisCommand:LeafCommand = .batteryUpdateRequest
        let thisMethod = self.requestbatteryUpdate
        
        if mainDriver.connectionState == .loggedIn{
            
            batteryUpdateResultKeyPublisher = restAPI.publish(method:.POST, command: thisCommand, parameters: parameters)
            
            batteryUpdateResultKeyReceiver = batteryUpdateResultKeyPublisher.sink(receiveCompletion: {completion in
                self.mainDriver.handle(completion: completion, of: thisCommand, recalOnFailure: thisMethod, callwhenSucceeded: self.checkCommandCompletion)
            },receiveValue: {value in
                if let batteryUpdateResultKey = value{
                    self.batteryUpdateResultKey = batteryUpdateResultKey
                }
            }
            )
        }else{
            mainDriver.commandQueue[thisCommand] = thisMethod
        }
        
    }
    
    private func checkCommandCompletion(){
        
        let thisCommand:LeafCommand = .BatteryUpdateRespons
        let thisMethod = self.checkCommandCompletion
        
        if mainDriver.connectionState == .loggedIn{
            
            batteryUpdateStatusPublisher = restAPI.publish(method:.POST, command: thisCommand, parameters: parameters)
            
            batteryUpdateStatusReceiver = batteryUpdateStatusPublisher
                .tryMap( { value in
                    if let BatteryUpdateRespons = value{
                        if BatteryUpdateRespons.responseFlag != "1"{
                            throw LeafDriverError.noResponse
                        }
                    }
                })
                .sink(receiveCompletion: {completion in
                    self.mainDriver.handle(completion: completion, of: thisCommand, recalOnFailure: thisMethod, callwhenSucceeded: self.parseBatteryUpdate)
                },receiveValue: {value in }
            )
        }else{
            mainDriver.commandQueue[thisCommand] = thisMethod
        }
        
    }
    
    private func parseBatteryUpdate(){
        
        let thisCommand:LeafCommand = .BatteryUpdateRespons
        let thisMethod = self.parseBatteryUpdate
        
        if mainDriver.connectionState == .loggedIn{
            
            batteryUpdateResponsPublisher = restAPI.publish(method:.POST, command: thisCommand, parameters: parameters)
            
            batteryUpdateResponsReceiver = batteryUpdateResponsPublisher
                .sink(receiveCompletion: {completion in
                    self.mainDriver.handle(completion: completion, of: thisCommand, recalOnFailure: thisMethod, callwhenSucceeded: {})
                },receiveValue: {value in
                    if let BatteryUpdateRespons = value{
                        if BatteryUpdateRespons.responseFlag == "1"{
                            self.batteryStatus?.batteryStatusRecords.cruisingRangeAcOff
                                = BatteryUpdateRespons.cruisingRangeAcOff
                            self.batteryStatus?.batteryStatusRecords.cruisingRangeAcOn
                                = BatteryUpdateRespons.cruisingRangeAcOn
                            self.batteryStatus?.batteryStatusRecords.timeRequiredToFull2006KW.hourRequiredToFull = BatteryUpdateRespons.timeRequiredToFull2006KW.hours
                            self.batteryStatus?.batteryStatusRecords.timeRequiredToFull2006KW.minutesRequiredToFull = BatteryUpdateRespons.timeRequiredToFull2006KW.minutes
                        }else{
                            self.mainDriver.commandQueue[thisCommand] = thisMethod
                            
                        }
                    }
                }
            )
        }else{
            mainDriver.commandQueue[thisCommand] = thisMethod
        }
        
    }
    
}
