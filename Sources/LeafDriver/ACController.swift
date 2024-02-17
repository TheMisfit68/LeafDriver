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
    
    init(mainDriver:LeafDriver){
        self.mainDriver = mainDriver
        restAPI = RestAPI(baseURL: mainDriver.restAPI.baseURL)
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
				self.airCoOnResultKey = try await restAPI.decode(method: .POST,
																 command: LeafCommand.airCoOnRequest,
																 includingBaseParameters: mainDriver.baseParameters,
																 timeout: 75)
                
				mainDriver.removeFromQueue(commandMethodPair)
                mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn)
                
			}  catch let error{
				mainDriver.handleLeafAPIError(error, for: commandMethodPair )
			}
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
																  timeout: 75)
				mainDriver.removeFromQueue(commandMethodPair)
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
															timeout: 75)
				mainDriver.removeFromQueue(commandMethodPair)
                mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn)
                
			} catch let error{
				mainDriver.handleLeafAPIError(error, for: commandMethodPair )
			}
			mainDriver.runCommandQueue()
        }
        
    }
    
}
