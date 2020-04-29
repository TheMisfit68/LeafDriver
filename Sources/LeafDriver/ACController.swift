//
//  ACController.swift
//  
//
//  Created by Jan Verrept on 25/04/2020.
//
import Foundation
import Combine
import SiriDriver

@available(OSX 10.15, *)
public class ACController:RestAPI<LeafCommand, LeafParameter>{
    
    unowned let mainDriver: LeafDriver
    unowned let siriDriver: SiriDriver
    
    var airCoStatusPublisher:AnyPublisher<AirCoStatus?, Error>!
    var airCoStatusReceiver:Cancellable!
    
    var airCoCommandResultKeyPublisher:AnyPublisher<AirCoCommandResultKey?, Error>!
    var airCoCommandResultKeyReceiver:Cancellable!
    var airCoCommandStatusPublisher:AnyPublisher<AirCoCommandStatus?, Error>!
    var airCoCommandStatusReceiver:Cancellable!
    var airCoUpdatePublisher:AnyPublisher<AirCoUpdate?, Error>!
    var airCoUpdateReceiver:Cancellable!
    
    public enum airCoState{
        case off
        case on
    }
    
    var airCoStatus:AirCoStatus?{
        didSet{
            //            if acState == .on{
            //                siriDriver.speak(text: "Airco ingeschakeld")
            //            }else{
            //                siriDriver.speak(text: "Airco uitgeschakeld")
            //            }
        }
    }
    
    var airCoCommandResultKey:AirCoCommandResultKey?
    
    var parameters:[LeafParameter:String]{
        
        var currentParameter:LeafParameter
        var currentParameters:[LeafParameter:String] = baseParameters.merging(mainDriver.parameters) {$1}
        
        // ResultKey
        currentParameter = LeafParameter.resultKey
        if let currentValue = airCoCommandResultKey?.resultKey{
            currentParameters[currentParameter] = currentValue
        }
        
        return currentParameters
        
    }
    init(mainDriver:LeafDriver){
        self.mainDriver = mainDriver
        self.siriDriver = mainDriver.siriDriver
        super .init(baseURL: mainDriver.baseURL, endpointParameters: mainDriver.endpointParameters)
    }
    
    
    public func getAirCoStatus(){
        
        let command:LeafCommand = .airCoStatus
        let thisMethod:LeafDriver.FunctionPointer = getAirCoStatus
        let maxRetries = 2
        if mainDriver.connectionState == .loggedIn{
            
            airCoStatusPublisher = publish(command: command, parameters: parameters)
            
            airCoStatusReceiver = airCoStatusPublisher.assertNoFailure().sink(receiveCompletion: {completion in},
                                                                              receiveValue: {value in
                                                                                if let airCoStatus = value{
                                                                                    self.airCoStatus = airCoStatus
                                                                                    self.mainDriver.removeFromQueue(command: command)
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
    
    public func setAirCo(to airCoState:airCoState){
        
        if airCoState == .on{
            setAirCoOn()
        }else{
            setAirCoOff()
        }
        
    }
    
    private func setAirCoOn(){
        
        let command:LeafCommand = .airCoOnRequest
        let thisMethod:LeafDriver.FunctionPointer = self.setAirCoOn
        let maxRetries = 2
        if mainDriver.connectionState == .loggedIn{
            
            airCoCommandResultKeyPublisher = publish(command: command, parameters: parameters)
            
            airCoCommandResultKeyReceiver = airCoCommandResultKeyPublisher.assertNoFailure().sink(receiveCompletion: {completion in},
                                                                                                  receiveValue: {value in
                                                                                                    if let airCoCommandResultKey = value{
                                                                                                        self.airCoCommandResultKey = airCoCommandResultKey
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
    
    private func setAirCoOff(){
        
        let command:LeafCommand = .airCoOffRequest
        let thisMethod:LeafDriver.FunctionPointer = self.setAirCoOff
        let maxRetries = 2
        if mainDriver.connectionState == .loggedIn{
            
            airCoCommandResultKeyPublisher = publish(command: command, parameters: parameters)
            
            airCoCommandResultKeyReceiver = airCoCommandResultKeyPublisher.assertNoFailure().sink(receiveCompletion: {completion in},
                                                                                                  receiveValue: {value in
                                                                                                    if let airCoCommandResultKey = value{
                                                                                                        self.airCoCommandResultKey = airCoCommandResultKey
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
        
        let command:LeafCommand = .airCoUpdate
        let thisMethod:LeafDriver.FunctionPointer = self.checkCommandCompletion
        let maxRetries = 10
        
        if mainDriver.connectionState == .loggedIn{
            
            airCoCommandStatusPublisher = publish(command: command, parameters: parameters)
            airCoCommandStatusReceiver = airCoCommandStatusPublisher.assertNoFailure().sink(receiveCompletion: {completion in},
                                                                                            receiveValue: {value in
                                                                                                if let airCoUpdate = value{
                                                                                                    if airCoUpdate.responseFlag == "1"{
                                                                                                        self.mainDriver.removeFromQueue(command: command)
                                                                                                        self.parseAirCoUpdate()
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
    
    private func parseAirCoUpdate(){
        
        let command:LeafCommand = .airCoUpdate
        let thisMethod:LeafDriver.FunctionPointer = self.parseAirCoUpdate
        let maxRetries = 2
        
        if mainDriver.connectionState == .loggedIn{
            
            airCoUpdatePublisher = publish(command: command, parameters: parameters)
            
            airCoUpdateReceiver = airCoUpdatePublisher.assertNoFailure().sink(receiveCompletion: {completion in},
                                                                                  receiveValue: {value in
                                                                                    if let airCoUpdate = value{
                                                                                        if airCoUpdate.responseFlag == "1"{
                                                                                            self.mainDriver.removeFromQueue(command: command)
                                                                                            
                                                                                            //TODO: - set aircoUpdate=>aircostatus?
//                                                                                            self.airCoStatus.
                                                                                            
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

