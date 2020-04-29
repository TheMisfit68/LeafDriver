//
//  Charger.swift
//
//
//  Created by Jan Verrept on 25/04/2020.
//

import Foundation
import Combine

@available(OSX 10.15, *)
public class Charger:RestAPI<LeafCommand, LeafParameter>{
    
    unowned let  mainDriver: LeafDriver?

    public enum ChargingState{
        case off
        case on
    }
    
    init(mainDriver:LeafDriver){
          self.mainDriver = mainDriver
          super .init(baseURL: mainDriver.baseURL, endpointParameters: mainDriver.endpointParameters)
    }
    
    public func getChargingState(){
        
    }
    
    public func setChargingState(to chargingState:ChargingState){
        
    }
}

