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
    
    var airCoOnResultKeyPublisher:AnyPublisher<AirCoOnResultKey?, Error>!
    var airCoOnResultKeyReceiver:Cancellable!
    var airCoOnStatusPublisher:AnyPublisher<AirCoOnStatus?, Error>!
    var airCoOnStatusReceiver:Cancellable!
    var airCoOnResponsPublisher:AnyPublisher<AirCoOnRespons?, Error>!
    var airCoOnResponsReceiver:Cancellable!
    
    var airCoOffResultKeyPublisher:AnyPublisher<AirCoOffResultKey?, Error>!
    var airCoOffResultKeyReceiver:Cancellable!
    var airCoOffStatusPublisher:AnyPublisher<AirCoOffStatus?, Error>!
    var airCoOffStatusReceiver:Cancellable!
    var airCoOffResponsPublisher:AnyPublisher<AirCoOffRespons?, Error>!
    var airCoOffResponsReceiver:Cancellable!
    
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
    
    var airCoOnResultKey:AirCoOnResultKey?
    var airCoOffResultKey:AirCoOffResultKey?
    
    var parameters:[LeafParameter:String]{
        
        var currentParameter:LeafParameter
        var currentParameters:[LeafParameter:String] = baseParameters.merging(mainDriver.parameters) {$1}
        
        // ResultKey
        currentParameter = LeafParameter.resultKey
        if let currentValue = airCoOnResultKey?.resultKey{
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
        let thisMethod = getAirCoStatus
        let maxRetries = 2
        if mainDriver.connectionState == .loggedIn{
            
            airCoStatusPublisher = publish(command: command, parameters: parameters, maxRetries: maxRetries)
            
            airCoStatusReceiver = airCoStatusPublisher
                .sink(receiveCompletion: {completion in},
                      receiveValue: {value in
                        if let airCoStatus = value{
                            self.airCoStatus = airCoStatus
                            self.mainDriver.connectionState = .loggedIn
                        }
                }
            )
        }else{
            mainDriver.commandQueue.add(command: command, function: thisMethod)
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
        let thisMethod = self.setAirCoOn
        let maxRetries = 2
        if mainDriver.connectionState == .loggedIn{
            
            airCoOnResultKeyPublisher = publish(command: command, parameters: parameters, maxRetries: maxRetries)
            
            airCoOnResultKeyReceiver = airCoOnResultKeyPublisher.sink(receiveCompletion: {completion in},
                                                                                        receiveValue: {value in
                                                                                            if let airCoOnResultKey = value{
                                                                                                self.airCoOnResultKey = airCoOnResultKey
                                                                                                self.checkAircoOnCompletion()
                                                                                                self.mainDriver.connectionState = .loggedIn
                                                                                            }
            }
            )
        }else{
            mainDriver.commandQueue.add(command: command, function: thisMethod)
        }
    }
    
    private func setAirCoOff(){
        
        let command:LeafCommand = .airCoOffRequest
        let thisMethod = self.setAirCoOff
        let maxRetries = 2
        if mainDriver.connectionState == .loggedIn{
            
            airCoOffResultKeyPublisher = publish(command: command, parameters: parameters, maxRetries: maxRetries)
            
            airCoOffResultKeyReceiver = airCoOffResultKeyPublisher.sink(receiveCompletion: {completion in},
                                                                                          receiveValue: {value in
                                                                                            if let airCoOffResultKey = value{
                                                                                                self.airCoOffResultKey = airCoOffResultKey
                                                                                                //                                                                                                self.checkAircoOffCompletion()
                                                                                                self.mainDriver.connectionState = .loggedIn
                                                                                            }
            }
            )
        }else{
            mainDriver.commandQueue.add(command: command, function: thisMethod)
        }
        
    }
    
    private func checkAircoOnCompletion(){
        
        let command:LeafCommand = .airCoUpdate
        let thisMethod = self.checkAircoOnCompletion
        let maxRetries = 10
        
        if mainDriver.connectionState == .loggedIn{
            
            airCoOnStatusPublisher = publish(command: command, parameters: parameters, maxRetries: maxRetries)
            airCoOnStatusReceiver = airCoOnStatusPublisher.sink(receiveCompletion: {completion in},
                                                                                  receiveValue: {value in
                                                                                    print("Test \(value)")
                                                                                    if let airCoUpdate = value{
                                                                                        if airCoUpdate.responseFlag == "1"{
                                                                                            self.parseAirCoOnRespons()
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
    
    private func parseAirCoOnRespons(){
        
        let command:LeafCommand = .airCoUpdate
        let thisMethod = self.parseAirCoOnRespons
        let maxRetries = 2
        
        if mainDriver.connectionState == .loggedIn{
            
            airCoOnResponsPublisher = publish(command: command, parameters: parameters, maxRetries: maxRetries)
            
            airCoOnResponsReceiver = airCoOnResponsPublisher.sink(receiveCompletion: {completion in},
                                                                                    receiveValue: {value in
                                                                                        print("airCoUpdate \(value)")
                                                                                        if let airCoUpdate = value{
                                                                                            if airCoUpdate.responseFlag == "1"{
                                                                                                
                                                                                                //TODO: - set aircoUpdate=>aircostatus?
                                                                                                //                                                                                            self.airCoStatus.
                                                                                                
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
