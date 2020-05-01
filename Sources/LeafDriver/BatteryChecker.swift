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
        let thisMethod = self.getBatteryStatus
        if mainDriver.connectionState == .loggedIn{
            
            batteryStatusPublisher = publish(command: command, parameters: parameters)
            
            batteryStatusReceiver = batteryStatusPublisher.sink(receiveCompletion: {completion in},
                                                                receiveValue: {value in
                                                                    if let batteryStatus = value{
                                                                        self.batteryStatus = batteryStatus
                                                                        self.requestbatteryUpdate()
                                                                        self.mainDriver.connectionState = .loggedIn
                                                                    }
                                                                    
                                                                    
            }
            )
        }else{
            mainDriver.commandQueue.add(command: command, function: thisMethod)
        }
        
    }
    
    private func requestbatteryUpdate(){
        
        let command:LeafCommand = .batteryUpdateRequest
        let thisMethod = self.requestbatteryUpdate
        
        if mainDriver.connectionState == .loggedIn{
            
            batteryUpdateResultKeyPublisher = publish(command: command, parameters: parameters)
            
            batteryUpdateResultKeyReceiver = batteryUpdateResultKeyPublisher.sink(receiveCompletion: {completion in},
                                                                                  receiveValue: {value in
                                                                                    if let batteryUpdateResultKey = value{
                                                                                        self.batteryUpdateResultKey = batteryUpdateResultKey
                                                                                        self.mainDriver.commandQueue.remove(command: command)
                                                                                        self.checkCommandCompletion()
                                                                                        
                                                                                        self.mainDriver.connectionState = .loggedIn
                                                                                    }
                                                                                    
                                                                                    
            }
            )
        }else{
            mainDriver.commandQueue.add(command: command, function: thisMethod)
        }
        
    }
    
    private func checkCommandCompletion(){
        
        let command:LeafCommand = .BatteryUpdateRespons
        let thisMethod = self.checkCommandCompletion
        
        if mainDriver.connectionState == .loggedIn{
            
            batteryUpdateStatusPublisher = publish(command: command, parameters: parameters, maxRetries: 10)
            
            batteryUpdateStatusReceiver = batteryUpdateStatusPublisher
                .sink(receiveCompletion: {completion in},
                      receiveValue: {value in
                        if let BatteryUpdateRespons = value{
                            if BatteryUpdateRespons.responseFlag == "1"{
                                self.mainDriver.commandQueue.remove(command: command)
                                self.parseBatteryUpdate()
                            }
                            self.mainDriver.connectionState = .loggedIn
                        }
                        
                }
            )
        }else{
            mainDriver.commandQueue.add(command: command, function: thisMethod)
        }
        
    }
    
    
    
    private func parseBatteryUpdate(){
        
        let command:LeafCommand = .BatteryUpdateRespons
        let thisMethod = self.parseBatteryUpdate
        
        if mainDriver.connectionState == .loggedIn{
            
            batteryUpdateResponsPublisher = publish(command: command, parameters: parameters)
            
            batteryUpdateResponsReceiver = batteryUpdateResponsPublisher
                .sink(receiveCompletion: {completion in},
                      receiveValue: {value in
                        if let BatteryUpdateRespons = value{
                            if BatteryUpdateRespons.responseFlag == "1"{
                                self.mainDriver.commandQueue.remove(command: command)
                                self.batteryStatus?.batteryStatusRecords.cruisingRangeAcOff
                                    = BatteryUpdateRespons.cruisingRangeAcOff
                                self.batteryStatus?.batteryStatusRecords.cruisingRangeAcOn
                                    = BatteryUpdateRespons.cruisingRangeAcOn
                                self.batteryStatus?.batteryStatusRecords.timeRequiredToFull2006KW.hourRequiredToFull = BatteryUpdateRespons.timeRequiredToFull2006KW.hours
                                self.batteryStatus?.batteryStatusRecords.timeRequiredToFull2006KW.minutesRequiredToFull = BatteryUpdateRespons.timeRequiredToFull2006KW.minutes
                            }else{
                                self.mainDriver.commandQueue.add(command: command, function: thisMethod)
                                
                            }
                            self.mainDriver.connectionState = .loggedIn
                        }
                }
            )
        }else{
            mainDriver.commandQueue.add(command: command, function: thisMethod)
        }
        
    }
    
}
