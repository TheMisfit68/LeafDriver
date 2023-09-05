//
//  Charger.swift
//
//
//  Created by Jan Verrept on 25/04/2020.
//

import Foundation
import Combine
import JVCocoa

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
        
        let thisCommand:LeafCommand = .startCharging
        let thisMethod = self.startCharging
        
        guard mainDriver.connectionState == .loggedIn else {mainDriver.commandQueue[thisCommand] = thisMethod; return}
        
        Task{
            do {
                self.startChargingResultKey = try await restAPI.decode(method: .POST, command: thisCommand, parameters: parameters)
                
                mainDriver.commandQueue.removeValue(forKey: thisCommand)
                mainDriver.connectionState = max(mainDriver.connectionState, .loggedIn)
                
            } catch LeafDriver.LeafAPI.Error.statusError{
                mainDriver.commandQueue[thisCommand] = thisMethod
                mainDriver.connectionState = min(mainDriver.connectionState, .disconnected)
            }    catch LeafDriver.LeafAPI.Error.decodingError{
                mainDriver.commandQueue[thisCommand] = thisMethod
                mainDriver.connectionState = min(mainDriver.connectionState, .connected)
            }
        }
        
    }
    
}

