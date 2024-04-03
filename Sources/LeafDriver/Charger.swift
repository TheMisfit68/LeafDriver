//
//  Charger.swift
//
//
//  Created by Jan Verrept on 25/04/2020.
//
import Foundation
import JVNetworking
import JVSwiftCore

@available(OSX 12.0, *)
public class Charger{
    
    unowned let mainDriver: LeafDriver
    
    var restAPI:LeafDriver.LeafAPI
    
    var startChargingResultKey:StartChargingResultKey?
	public var chargingWasExecuted:Bool?
    
    
	init(mainDriver:LeafDriver){
		self.mainDriver = mainDriver
		restAPI = RestAPI(baseURL: mainDriver.restAPI.baseURL)
    }
    
	
    public func startCharging(){
        
		self.chargingWasExecuted = nil
		let commandMethodPair:LeafDriver.LeafCommandMethodPair = (command:.startCharging , method:self.startCharging)
		guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue.enqueue(commandMethodPair); return}
        
        Task{
            do {
				self.startChargingResultKey = try await restAPI.decode(method: .POST,
																	   command: LeafCommand.startCharging,
																	   includingBaseParameters: mainDriver.baseParameters,
																	   dateDecodingStrategy: .iso8601,
																	   timeout: 75)
				
				mainDriver.removeFromQueue(commandMethodPair)
				mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn)
				self.chargingWasExecuted = true
				
			} catch let error{
				mainDriver.handleLeafAPIError(error, for: commandMethodPair )
			}
			mainDriver.runCommandQueue()
        }
        
    }
    
}

