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

    public enum ChargingState{
        case off
        case on
    }
    
    var parameters:[LeafParameter:String]{
        
        var currentParameters:[LeafParameter:String] = mainDriver.parameters
        var currentParameter:LeafParameter
        
        return currentParameters
    }
    
    init(mainDriver:LeafDriver){
          self.mainDriver = mainDriver
          restAPI = RestAPI<LeafCommand, LeafParameter>(baseURL: mainDriver.restAPI.baseURL, endpointParameters: mainDriver.restAPI.endpointParameters)
    }
    
    public func getChargingState(){
        
    }
    
    public func setChargingState(to chargingState:ChargingState){
        
    }
}

