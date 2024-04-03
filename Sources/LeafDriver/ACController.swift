//
//  ACController.swift
//
//
//  Created by Jan Verrept on 25/04/2020.
//
import Foundation
import JVNetworking
import JVSwiftCore

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
	
	public var aircoIsRunning:Bool? = nil
    
    init(mainDriver:LeafDriver){
        self.mainDriver = mainDriver
        restAPI = RestAPI(baseURL: mainDriver.restAPI.baseURL)
    }

    public func setAirCo(to airCoState:airCoState){
        
		aircoIsRunning = nil // From here on wait for a brand new status-feedback
		
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
				self.airCoOnResultKey = try await restAPI.decode(method: .POST,
																 command: LeafCommand.airCoOnRequest,
																 includingBaseParameters: mainDriver.baseParameters,
																 dateDecodingStrategy: .iso8601,
																 timeout: 75)
                
				mainDriver.removeFromQueue(commandMethodPair)
				
				let nextCommandAndMethod:LeafDriver.LeafCommandMethodPair = (command:.airCoStatus, method:getAirCoStatus)
				mainDriver.commandQueue.enqueue(nextCommandAndMethod)
                mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn)
			}  catch let error{
				mainDriver.handleLeafAPIError(error, for: commandMethodPair )
			}
			mainDriver.runCommandQueue()
        }
    }
    
    
    private func setAirCoOff(){
		 
		let commandMethodPair:LeafDriver.LeafCommandMethodPair = (command:.airCoOffRequest , method:self.setAirCoOff)
		guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue.enqueue(commandMethodPair); return}

        Task{
            do {
				self.airCoOffResultKey = try await restAPI.decode(method: .POST,
																  command: LeafCommand.airCoOffRequest,
																  includingBaseParameters: mainDriver.baseParameters,
																  dateDecodingStrategy: .iso8601,
																  timeout: 75)
				mainDriver.removeFromQueue(commandMethodPair)
				
				let nextCommandAndMethod:LeafDriver.LeafCommandMethodPair = (command:.airCoStatus, method:getAirCoStatus)
				mainDriver.commandQueue.enqueue(nextCommandAndMethod)
                mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn)
			} catch let error{
				mainDriver.handleLeafAPIError(error, for: commandMethodPair )
			}
			mainDriver.runCommandQueue()
        }
    }
    
    public func getAirCoStatus(){
        
		let commandMethodPair:LeafDriver.LeafCommandMethodPair = (command:.airCoStatus , method:self.getAirCoStatus)
		guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue.enqueue(commandMethodPair); return}
        
        Task{
            do {
				self.airCoStatus = try await restAPI.decode(method: .POST,
															command: LeafCommand.airCoStatus,
															includingBaseParameters: mainDriver.baseParameters,
															dateDecodingStrategy: .iso8601,
															timeout: 120)
				mainDriver.removeFromQueue(commandMethodPair)
                mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn)
				aircoIsRunning = (airCoStatus!.remoteAcRecords.remoteAcOperation == "START")
                
			} catch let error{
				mainDriver.handleLeafAPIError(error, for: commandMethodPair )
			}
			mainDriver.runCommandQueue()
        }
        
    }
    
}
