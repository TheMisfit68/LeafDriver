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
    
    
    var parameters:[LeafParameter:String]{
        mainDriver.parameters
    }
    
    init(mainDriver:LeafDriver){
        self.mainDriver = mainDriver
        restAPI = RestAPI<LeafCommand, LeafParameter>(baseURL: mainDriver.restAPI.baseURL, endpointParameters: mainDriver.restAPI.endpointParameters)
    }
    
	
    public func startCharging(){
        
		let commandMethodPair:LeafDriver.LeafCommandMethodPair = (command:.startCharging , method:self.startCharging)
		guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue.enqueue(commandMethodPair); return}
        
        Task{
            do {
				self.startChargingResultKey = try await restAPI.decode(method: .POST, command: .startCharging, parameters: parameters)
                
				mainDriver.removeFromQueue(commandMethodPair)
				mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn)
                
			} catch let error as LeafDriver.LeafAPI.Error{
				mainDriver.handleLeafAPIError(error, for: commandMethodPair )
			}
        }
        
    }
    
}

