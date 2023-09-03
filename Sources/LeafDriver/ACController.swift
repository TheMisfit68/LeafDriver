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

@available(OSX 12.0, *)
public class ACController{
    
    unowned let mainDriver: LeafDriver
    unowned let siriDriver: SiriDriver
    
    var restAPI:LeafDriver.LeafAPI
    
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
        guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue[thisCommand] = thisMethod; return}
        
        
        Task{
            do {
                self.airCoStatus = try await restAPI.decode(method: .POST, command: thisCommand, parameters: parameters)
                
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
        
        guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue[thisCommand] = thisMethod; return}
        
        
        Task{
            do {
                self.airCoOnResultKey = try await restAPI.decode(method: .POST, command: thisCommand, parameters: parameters)
                self.checkAircoOnCompletion()
                
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
    
    
    private func setAirCoOff(){
        
        let thisCommand:LeafCommand = .airCoOffRequest
        let thisMethod = setAirCoOff
        
        guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue[thisCommand] = thisMethod; return}
        
        
        Task{
            do {
                self.airCoOffResultKey = try await restAPI.decode(method: .POST, command: thisCommand, parameters: parameters)
                
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
    
    
    
    private func checkAircoOnCompletion(){
        
        let thisCommand:LeafCommand = .airCoUpdate
        let thisMethod = checkAircoOnCompletion
        
        guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue[thisCommand] = thisMethod; return}
        
        Task{
            do {
                let airCoUpdate:AirCoOnRespons? = try await restAPI.decode(method: .POST, command: thisCommand, parameters: parameters)
                guard airCoUpdate?.responseFlag == "1" else { mainDriver.commandQueue[thisCommand] = thisMethod; return}
                
                self.parseAirCoOnRespons()
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
    
    private func parseAirCoOnRespons(){
        
        // TODO: - Reimplement this function after succesful test of Async Await-methods
        //        let thisCommand:LeafCommand = .airCoUpdate
        //        let thisMethod = parseAirCoOnRespons
        //
        //        if mainDriver.connectionState == .loggedIn{
        //
        //            airCoOnResponsPublisher = restAPI.publish(method:.POST, command: thisCommand, parameters: parameters)
        //
        //            airCoOnResponsReceiver = airCoOnResponsPublisher
        //                .sink(receiveCompletion: {completion in
        //                    self.mainDriver.handle(completion: completion, of: thisCommand, recalOnFailure: thisMethod, callwhenSucceeded: {})
        //                },
        //                      receiveValue: {value in
        //                        if let airCoUpdate = value{
        //                            if airCoUpdate.responseFlag == "1"{
        //								logger.info("airCoUpdate \(String(describing: value), privacy: .public)")
        //
        //                                //TODO: - set aircoUpdate=>aircostatus?
        //                                //                                                                                            self.airCoStatus.
        //
        //                            }else{
        //                                self.mainDriver.commandQueue[thisCommand] = thisMethod
        //                            }
        //
        //                        }
        //
        //
        //                }
        //            )
        //        }
        //
    }
    
    
}
