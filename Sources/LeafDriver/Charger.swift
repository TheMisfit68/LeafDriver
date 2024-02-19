//
//  Charger.swift
//
//
//  Created by Jan Verrept on 25/04/2020.
//

import Foundation
import Combine
import JVSwift
import JVNetworking

@available(OSX 12.0, *)
public class Charger{
    
    unowned let mainDriver: LeafDriver
    
    var restAPI:LeafDriver.LeafAPI
    
    var startChargingResultKey:StartChargingResultKey?
    
    
	init(mainDriver:LeafDriver){
		self.mainDriver = mainDriver
		restAPI = RestAPI(baseURL: mainDriver.restAPI.baseURL)
    }
    
	
    public func startCharging(){
        
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
                
			} catch let error{
				mainDriver.handleLeafAPIError(error, for: commandMethodPair )
			}
			mainDriver.runCommandQueue()
        }
        
    }
    
}

