////
////  LeafDriver.swift
////  
////
////  Created by Jan Verrept on 28/10/2021.
////
//
//import Foundation
//import Combine
//
//// MARK: - Combine version
//
//@available(OSX 11.0, *)
////extension LeafDriver{
//	
//	internal func handle(completion:Subscribers.Completion<Swift.Error>,of command:LeafCommand, recalOnFailure:@escaping AnyMethod, callwhenSucceeded:@escaping AnyMethod){
//		
//		switch completion{
//		case .finished:
//			
//			commandQueue.removeValue(forKey: command)
//			commandQueue[command] = callwhenSucceeded
//			
//			if command == .connect {
//				connectionState = max(connectionState, .connected)
//			}else{
//				connectionState = max(connectionState, .loggedIn)
//			}
//			
//		case .failure(let error):
//			
//			commandQueue[command] = recalOnFailure
//			
//			switch error{
//			case URLError.notConnectedToInternet:
//				connectionState = min(connectionState, .disconnected)
//			case DecodingError.keyNotFound:
//				if command == .connect {
//					connectionState = min(connectionState, .disconnected)
//				}else if command == .login{
//					connectionState = min(connectionState, .connected)
//				}else{
//					connectionState = min(connectionState, .loggedIn)
//				}
//			default:
//				connectionState = .unknown
//			}
//			
//		}
//	}
//	
//}
