//
//  ACController.swift
//  
//
//  Created by Jan Verrept on 25/04/2020.
//
import Foundation
import JVCocoa
import Combine
import SiriDriver

@available(OSX 10.15, *)
public class ACController{
    
    unowned let mainDriver: LeafDriver
    unowned let siriDriver: SiriDriver
    
    var restAPI:RestAPI<LeafCommand, LeafParameter>
    
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
            
        }
    }
    
    var airCoOnResultKey:AirCoOnResultKey?
    var airCoOffResultKey:AirCoOffResultKey?
    
    var parameters:[LeafParameter:String]{
        
        var currentParameters:[LeafParameter:String] = mainDriver.parameters
        var currentParameter:LeafParameter
        
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
        restAPI = RestAPI<LeafCommand, LeafParameter>(baseURL: mainDriver.restAPI.baseURL, endpointParameters: mainDriver.restAPI.endpointParameters)
    }
    
    
    public func getAirCoStatus(){
        
        let thisCommand:LeafCommand = .airCoStatus
        let thisMethod = getAirCoStatus
        if mainDriver.connectionState == .loggedIn{
            
            airCoStatusPublisher = restAPI.publish(method:.POST, command: thisCommand, parameters: parameters)
            
            airCoStatusReceiver = airCoStatusPublisher
                .sink(receiveCompletion: {completion in
                    self.mainDriver.handle(completion: completion, of: thisCommand, recalOnFailure: thisMethod, callwhenSucceeded: {})
                },receiveValue: {value in
                    if let airCoStatus = value{
                        self.airCoStatus = airCoStatus
                    }
                }
            )
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
        
        let thisCommand:LeafCommand = .airCoOnRequest
        let thisMethod = setAirCoOn
        
        if mainDriver.connectionState == .loggedIn{
            
            airCoOnResultKeyPublisher = restAPI.publish(method:.POST, command: thisCommand, parameters: parameters)
            
            airCoOnResultKeyReceiver = airCoOnResultKeyPublisher
                .sink(receiveCompletion: {completion in
                    self.mainDriver.handle(completion: completion, of: thisCommand, recalOnFailure: thisMethod, callwhenSucceeded: {})
                },receiveValue: {value in
                    if let airCoOnResultKey = value{
                        self.airCoOnResultKey = airCoOnResultKey
                        self.checkAircoOnCompletion()
                    }
                }
            )
        }
    }
    
    private func setAirCoOff(){
        
        let thisCommand:LeafCommand = .airCoOffRequest
        let thisMethod = setAirCoOff
        
        if mainDriver.connectionState == .loggedIn{
            
            airCoOffResultKeyPublisher = restAPI.publish(method:.POST, command: thisCommand, parameters: parameters)
            
            airCoOffResultKeyReceiver = airCoOffResultKeyPublisher
                .sink(receiveCompletion: {completion in
                    self.mainDriver.handle(completion: completion, of: thisCommand, recalOnFailure: thisMethod, callwhenSucceeded: {})
                },receiveValue: {value in
                    if let airCoOffResultKey = value{
                        self.airCoOffResultKey = airCoOffResultKey
                    }
                }
            )
        }
    }
    
    private func checkAircoOnCompletion(){
        
        let thisCommand:LeafCommand = .airCoUpdate
        let thisMethod = checkAircoOnCompletion
        
        if mainDriver.connectionState == .loggedIn{
            
            airCoOnStatusPublisher = restAPI.publish(method:.POST, command: thisCommand, parameters: parameters, maxRetries: 10)
            airCoOnStatusReceiver = airCoOnStatusPublisher
                .sink(receiveCompletion: {completion in
                    self.mainDriver.handle(completion: completion, of: thisCommand, recalOnFailure: thisMethod, callwhenSucceeded: {})
                },receiveValue: {value in
                    if let airCoUpdate = value{
                        if airCoUpdate.responseFlag == "1"{
                            self.parseAirCoOnRespons()
                        }
                    }
                    
                }
            )
        }

    }
    
    private func parseAirCoOnRespons(){
        
        let thisCommand:LeafCommand = .airCoUpdate
        let thisMethod = parseAirCoOnRespons
        
        if mainDriver.connectionState == .loggedIn{
            
            airCoOnResponsPublisher = restAPI.publish(method:.POST, command: thisCommand, parameters: parameters)
            
            airCoOnResponsReceiver = airCoOnResponsPublisher
                .sink(receiveCompletion: {completion in
                    self.mainDriver.handle(completion: completion, of: thisCommand, recalOnFailure: thisMethod, callwhenSucceeded: {})
                },
                      receiveValue: {value in
                        if let airCoUpdate = value{
                            if airCoUpdate.responseFlag == "1"{
								Debugger.shared.log(debugLevel:.Native(logType: .info), "airCoUpdate \(String(describing: value))")

                                //TODO: - set aircoUpdate=>aircostatus?
                                //                                                                                            self.airCoStatus.
                                
                            }else{
                                self.mainDriver.commandQueue[thisCommand] = thisMethod
                            }
                            
                        }
                        
                        
                }
            )
        }
        
    }
    
    
}
