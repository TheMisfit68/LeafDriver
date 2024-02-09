//
//  LeafDriver.swift
//
//
//  Created by Jan Verrept on 26/03/2020.
//

import Foundation
import JVSwift
import JVSwiftCore
import JVSecurity
import JVNetworking
import Combine
import CryptoSwift
import OSLog


@available(OSX 12.0, *)
open class LeafDriver:Configurable, Securable{
	let logger = Logger(subsystem: "be.oneclick.LeafDriver", category:"LeafDriver")
	
	var leafProtocol:LeafProtocol
	
	public let notificationKey:String = "LeafDriverSettingsChanged"
	
	public func reloadSettings(){
		
		// Read the credentials
		let userCredentials = internetCredentialsFromKeyChain(name: "LeafDriver", location: "be.oneclick.LeafDriver")
		let userName = userCredentials?.account ?? ""
		let password = userCredentials?.password ?? ""
		
		// Read te parameters from the Preferences…
		let settings = UserDefaults(suiteName: "be.oneclick.jan.LeafDriver")
		
		let userParameters:[LeafParameter:String] = [
			.initialAppStr: leafProtocol.initialAppString,
			.userID: userName,
			.clearPassWord: password,
			.regionCode: settings?.string(forKey: "regionCode") ?? "",
			.language: settings?.string(forKey: "language") ?? "",
			.timeZone: settings?.string(forKey: "timeZone") ?? ""
		]
		
		self.restAPI = RestAPI<LeafCommand, LeafParameter>(baseURL: leafProtocol.baseURL, endpointParameters: leafProtocol.requiredCommandParameters, baseValues: userParameters)
		
	}
	
	public typealias AnyLeafMethod = () -> Void
	public typealias LeafCommandMethodPair = (command:LeafCommand,method:AnyLeafMethod)
	public var commandQueue = Queue<LeafCommandMethodPair> ()
	
	public typealias LeafAPI = RestAPI<LeafCommand, LeafParameter>
	var restAPI:LeafAPI!
	
	public enum ConnectionState:Int, Comparable{
		
		case disconnected
		case connected
		case loggedIn
		
		// Conform to comparable
		public static func < (a: ConnectionState, b: ConnectionState) -> Bool {
			return a.rawValue < b.rawValue
		}
	}
	
	public var connectionState:ConnectionState = .disconnected
	
	internal var isIdle:Bool{
		connectionState == .loggedIn && commandQueue.isEmpty
	}
	
	public var batteryChecker:BatteryChecker!
	public var acController:ACController!
	public var charger:Charger!
	
	var connectionInfo:ConnectionInfo?
	var session:Session?
	
	private var queueTimer:Timer?
	private var queueTime:TimeInterval = 60
	internal var holdCommandQueue:Bool{
		
		// Autoreset this boolean after a whileany
		didSet{
			
			self.queueTimer?.invalidate()
			self.queueTimer = nil
			
			if holdCommandQueue {
				
				// Use the main thread to create the reset timer because a timer requires a run loop
				DispatchQueue.main.async {
					self.queueTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false) { [weak self] _ in
						self?.holdCommandQueue.reset()
						self?.runCommandQueue()
					}
					self.queueTimer!.tolerance = self.queueTimer!.timeInterval/10.0 // Give the processor some slack with a 10% tolerance on the interval
				}
			}
		}
	}
	
	
	var parameters:[LeafParameter:String]{
		
		var currentParameters:[LeafParameter:String] = [:]
		var currentParameter:LeafParameter
		
		func encryptUsingBlowfish(password:String, key:String)->String{
			
			let password = Array(password.utf8)
			let key = Array(key.utf8)
			
			let blowFishEncryptor = try? Blowfish(key: key, blockMode: ECB(), padding: .pkcs5)
			let encryptedPassword =  try? blowFishEncryptor?.encrypt(password).toBase64()
			return encryptedPassword ?? ""
			
		}
		
		// User
		// UserID
		currentParameter = LeafParameter.userID
		if let currentValue = session?.customerInfo.eMailAddress{
			currentParameters[currentParameter] = currentValue
		}
		
		// Password
		currentParameter = LeafParameter.encryptedPassWord
		if let clearPassWord:String = restAPI.baseValues[.clearPassWord],
		   let encryptionkey:String = connectionInfo?.baseprm{
			let currentValue = encryptUsingBlowfish(password: clearPassWord, key:encryptionkey)
			currentParameters[currentParameter] = currentValue
		}
		
		// RegionCode
		currentParameter = LeafParameter.regionCode
		if let currentValue = session?.customerInfo.regionCode{
			currentParameters[currentParameter] = currentValue
		}
		
		// Timezone
		currentParameter = LeafParameter.timeZone
		if let currentValue = session?.customerInfo.timezone{
			currentParameters[currentParameter] = currentValue
		}
		
		// Language
		currentParameter = LeafParameter.language
		if let currentValue = session?.customerInfo.language{
			currentParameters[currentParameter] = currentValue
		}
		
		// Session
		// SessionID
		currentParameter = LeafParameter.customSessionID
		if let currentValue = session?.vehicleInfoList.vehicleInfoListVehicleInfo.first?.customSessionid{
			currentParameters[currentParameter] = currentValue
		}
		
		// Vehicle
		// VIN
		currentParameter = LeafParameter.vin
		if let currentValue = session?.vehicleInfoList.vehicleInfoListVehicleInfo.first?.vin{
			currentParameters[currentParameter] = currentValue
		}
		
		// DCMID
		currentParameter = LeafParameter.dcmid
		if let currentValue = session?.vehicle.profile.dcmId{
			currentParameters[currentParameter] = currentValue
		}
		
		return currentParameters
	}
	
	public init(leafProtocol:LeafProtocol){
		
		// Read the credentials
		self.leafProtocol = leafProtocol
		self.queueTimer = nil
		self.holdCommandQueue = false
		
		self.reloadSettings()
		self.observeNotifications()
		
		self.batteryChecker = BatteryChecker(mainDriver: self)
		self.acController = ACController(mainDriver: self)
		self.charger = Charger(mainDriver: self)
		
		self.connect()
		
	}
	
	
	private func connect(){
		
		Task{
			do {
				self.connectionInfo = try await restAPI.decode(method:RestAPI.Method.POST, command: .connect, parameters: parameters)
				connectionState = max(connectionState, .connected)
				logger.info("Leafdriver connected succesfully")
				runCommandQueue()
			} catch let error as LeafDriver.LeafAPI.Error{
				handleLeafAPIError(error)
			}
		}
		
	}
	
	
	
	private func login(){
		
		Task{
			do {
				self.session = try await restAPI.decode(method:RestAPI.Method.POST, command: .login, parameters: parameters)
				connectionState = max(connectionState, .loggedIn)
				logger.info("Leafdriver logged in succesfully")
				runCommandQueue()
			} catch let error as LeafDriver.LeafAPI.Error{
				handleLeafAPIError(error)
			}
		}
		
	}
	
	internal func runCommandQueue(){
		
		if !holdCommandQueue{
			
			switch connectionState {
				case .disconnected:
					connect()
					self.queueTime = 10
				case .connected:
					login()
					self.queueTime = 20
				case .loggedIn:
					if let method = commandQueue.nextElement?.method {
						method()
					}
					self.queueTime = 60
			}
			
			holdCommandQueue.set()
		}
		
	}
	
	internal func removeFromQueue(_ commandMethodPair:LeafCommandMethodPair){
		if let queuedCommand = commandQueue.nextElement?.command, commandMethodPair.command == queuedCommand{
			commandQueue.removeElement()
		}
	}
	
	internal func handleLeafAPIError(_ error: LeafDriver.LeafAPI.Error, for commandMethodPair: LeafCommandMethodPair? = nil) {
		
		switch error {
			case .statusError:
				connectionState = .disconnected
			case .timeoutError:
				connectionState = .disconnected
			case .decodingError:
				connectionState = .connected
		}
		if let commandMethodPair = commandMethodPair{
			commandQueue.enqueue( commandMethodPair )
		}
		
	}
	
}
