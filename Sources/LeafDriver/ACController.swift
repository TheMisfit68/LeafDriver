//
//  ACController.swift
//
//
//  Created by Jan Verrept on 25/04/2020.
//
import Foundation
import JVSwift
import JVNetworking
import Combine

@available(OSX 12.0, *)
public class ACController{
    
    unowned let mainDriver: LeafDriver
    
    var restAPI:LeafDriver.LeafAPI
    
    public enum airCoState{
        case off
        case on
    }
    
    var airCoStatus:AirCoStatus?
    
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
        restAPI = RestAPI<LeafCommand, LeafParameter>(baseURL: mainDriver.restAPI.baseURL, endpointParameters: mainDriver.restAPI.endpointParameters)
    }

    
    
    public func setAirCo(to airCoState:airCoState){
        
        if airCoState == .on{
            setAirCoOn()
        }else{
            setAirCoOff()
        }
        
    }
    
    private func setAirCoOn(){
                
		let commandMethodPair:LeafDriver.LeafCommandMethodPair = (command:.airCoOnRequest , method:self.setAirCoOn)
		guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue.enqueue(commandMethodPair); return}
        
        
        Task{
            do {
				self.airCoOnResultKey = try await restAPI.decode(method: .POST, command: .airCoOnRequest, parameters: parameters)
                
				mainDriver.removeFromQueue(commandMethodPair)
                mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn)
                
			}  catch let error as LeafDriver.LeafAPI.Error{
				mainDriver.handleLeafAPIError(error, for: commandMethodPair )
			}
        }
    }
    
    
    private func setAirCoOff(){
		        
		let commandMethodPair:LeafDriver.LeafCommandMethodPair = (command:.airCoOffRequest , method:self.setAirCoOff)
		guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue.enqueue(commandMethodPair); return}

        Task{
            do {
				self.airCoOffResultKey = try await restAPI.decode(method: .POST, command: .airCoOffRequest, parameters: parameters)
                
				mainDriver.removeFromQueue(commandMethodPair)
                mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn)
                
			} catch let error as LeafDriver.LeafAPI.Error{
				mainDriver.handleLeafAPIError(error, for: commandMethodPair )
			}
        }
    }
    
    public func getAirCoStatus(){
        
		let commandMethodPair:LeafDriver.LeafCommandMethodPair = (command:.airCoStatus , method:self.getAirCoStatus)
		guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue.enqueue(commandMethodPair); return}
        
        Task{
            do {
				self.airCoStatus = try await restAPI.decode(method: .POST, command: .airCoStatus, parameters: parameters)
                
				mainDriver.removeFromQueue(commandMethodPair)
                mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn)
                
			} catch let error as LeafDriver.LeafAPI.Error{
				mainDriver.handleLeafAPIError(error, for: commandMethodPair )
			}
        }
        
    }
    
}
