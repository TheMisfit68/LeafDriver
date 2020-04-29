//
//  BatteryChecker.swift
//  
//
//  Created by Jan Verrept on 25/04/2020.
//

import Foundation
import Combine
import SiriDriver

@available(OSX 10.15, *)
public class BatteryChecker:RestAPI<LeafCommand, LeafParameter>{
    
    unowned let mainDriver: LeafDriver
    unowned let siriDriver: SiriDriver
    
    var batteryStatusPublisher:AnyPublisher<BatteryStatus?, Error>!
    var batteryStatusReceiver:Cancellable!
    
    var batteryUpdateResultKeyPublisher:AnyPublisher<BatteryUpdateResultKey?, Error>!
    var batteryUpdateResultKeyReceiver:Cancellable!
    var batteryUpdateStatusPublisher:AnyPublisher<BatteryUpdateStatus?, Error>!
    var batteryUpdateStatusReceiver:Cancellable!
    var batteryUpdatePublisher:AnyPublisher<BatteryUpdate?, Error>!
    var batteryUpdateReceiver:Cancellable!
    
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
        
        var currentParameter:LeafParameter
        var currentParameters:[LeafParameter:String] = baseParameters.merging(mainDriver.parameters) {$1}
        
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
        super .init(baseURL: mainDriver.baseURL, endpointParameters: mainDriver.endpointParameters)
    }
    
    
    public func getBatteryStatus(){
        
        let command:LeafCommand = .batteryStatus
        let thisMethod:LeafDriver.FunctionPointer = self.getBatteryStatus
        let maxRetries = 2
        if mainDriver.connectionState == .loggedIn{
            
            batteryStatusPublisher = publish(command: command, parameters: parameters)
            
            batteryStatusReceiver = batteryStatusPublisher.assertNoFailure().sink(receiveCompletion: {completion in},
                                                                                  receiveValue: {value in
                                                                                    if let batteryStatus = value{
                                                                                        self.batteryStatus = batteryStatus
                                                                                        self.mainDriver.removeFromQueue(command: command)
                                                                                        self.requestbatteryUpdate()
                                                                                        self.mainDriver.connectionState = .loggedIn
                                                                                    }else{
                                                                                        self.mainDriver.addToQueue(command: command, function:
                                                                                            thisMethod,maxRetries: maxRetries)
                                                                                        self.mainDriver.connectionState = .failed
                                                                                    }
                                                                                    
                                                                                    
            }
            )
        }else{
            mainDriver.addToQueue(command: command, function: thisMethod)
        }
        
    }
    
    private func requestbatteryUpdate(){
        
        let command:LeafCommand = .batteryUpdateRequest
        let thisMethod:LeafDriver.FunctionPointer = self.requestbatteryUpdate
        let maxRetries = 2
        
        if mainDriver.connectionState == .loggedIn{
            
            batteryUpdateResultKeyPublisher = publish(command: command, parameters: parameters)
            
            batteryUpdateResultKeyReceiver = batteryUpdateResultKeyPublisher.assertNoFailure().sink(receiveCompletion: {completion in},
                                                                                                      receiveValue: {value in
                                                                                                        if let batteryUpdateResultKey = value{
                                                                                                            self.batteryUpdateResultKey = batteryUpdateResultKey
                                                                                                            self.mainDriver.removeFromQueue(command: command)
                                                                                                            self.checkCommandCompletion()
                                                                                                            
                                                                                                            self.mainDriver.connectionState = .loggedIn
                                                                                                            
                                                                                                        }else{
                                                                                                            self.mainDriver.addToQueue(command: command, function:
                                                                                                                thisMethod,maxRetries: maxRetries)
                                                                                                            self.mainDriver.connectionState = .failed
                                                                                                        }
                                                                                                        
                                                                                                        
            }
            )
        }else{
            mainDriver.addToQueue(command: command, function: thisMethod)
        }
        
    }
    
    private func checkCommandCompletion(){
        
        let command:LeafCommand = .batteryUpdate
        let thisMethod:LeafDriver.FunctionPointer = self.checkCommandCompletion
        let maxRetries = 10
        
        if mainDriver.connectionState == .loggedIn{
            
            batteryUpdateStatusPublisher = publish(command: command, parameters: parameters)
            batteryUpdateStatusReceiver = batteryUpdateStatusPublisher.assertNoFailure().sink(receiveCompletion: {completion in},
                                                                                                receiveValue: {value in
                                                                                                    if let batteryUpdate = value{
                                                                                                        if batteryUpdate.responseFlag == "1"{
                                                                                                            self.mainDriver.removeFromQueue(command: command)
                                                                                                            self.parseBatteryUpdate()
                                                                                                        }else{
                                                                                                            self.mainDriver.addToQueue(command: command, function:
                                                                                                                thisMethod,maxRetries: maxRetries)
                                                                                                        }
                                                                                                        self.mainDriver.connectionState = .loggedIn
                                                                                                    }else{
                                                                                                        self.mainDriver.addToQueue(command: command, function:
                                                                                                            thisMethod,maxRetries: maxRetries)
                                                                                                        self.mainDriver.connectionState = .failed
                                                                                                    }
                                                                                                    
            }
            )
        }else{
            mainDriver.addToQueue(command: command, function: thisMethod)
        }
        
    }
    
    
    
    private func parseBatteryUpdate(){
        
        let command:LeafCommand = .batteryUpdate
        let thisMethod:LeafDriver.FunctionPointer = self.parseBatteryUpdate
        let maxRetries = 2
        
        if mainDriver.connectionState == .loggedIn{
            
            batteryUpdatePublisher = publish(command: command, parameters: parameters)
            
            batteryUpdateReceiver = batteryUpdatePublisher.assertNoFailure().sink(receiveCompletion: {completion in},
                                                                                  receiveValue: {value in
                                                                                    if let batteryUpdate = value{
                                                                                        if batteryUpdate.responseFlag == "1"{
                                                                                            self.mainDriver.removeFromQueue(command: command)
                                                                                            self.batteryStatus?.batteryStatusRecords.cruisingRangeAcOff
                                                                                                = batteryUpdate.cruisingRangeAcOff
                                                                                            self.batteryStatus?.batteryStatusRecords.cruisingRangeAcOn
                                                                                                = batteryUpdate.cruisingRangeAcOn
                                                                                            self.batteryStatus?.batteryStatusRecords.timeRequiredToFull2006KW.hourRequiredToFull = batteryUpdate.timeRequiredToFull2006KW.hours
                                                                                            self.batteryStatus?.batteryStatusRecords.timeRequiredToFull2006KW.minutesRequiredToFull = batteryUpdate.timeRequiredToFull2006KW.minutes
                                                                                        }else{
                                                                                            self.mainDriver.addToQueue(command: command, function:
                                                                                                thisMethod,maxRetries: maxRetries)
                                                                                        }
                                                                                        self.mainDriver.connectionState = .loggedIn
                                                                                        
                                                                                    }else{
                                                                                        self.mainDriver.addToQueue(command: command, function:
                                                                                            thisMethod,maxRetries: maxRetries)
                                                                                        self.mainDriver.connectionState = .failed
                                                                                    }
                                                                                    
                                                                                    
            }
            )
        }else{
            mainDriver.addToQueue(command: command, function: thisMethod)
        }
        
    }
    
}
