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
	
	struct UserSettings{
		
		var userID:String
		var clearPassWord:String
		var regionCode:String
		var language:String
		var timeZone:String
		
		func encryptedPassWord(withKey encryptionKey:String)->String{
			
			let password = Array(self.clearPassWord.utf8)
			let key = Array(encryptionKey.utf8)
			
			let blowFishEncryptor = try? Blowfish(key: key, blockMode: ECB(), padding: .pkcs5)
			let encryptedPassword =  try? blowFishEncryptor?.encrypt(password).toBase64()
			return encryptedPassword ?? ""
		}
		
	}
	var userSettings:UserSettings! // Made explicitly unwrapped because it is initialized with the reloadSettings method
	
	public func reloadSettings(){
		
		// Read the credentials
		let userCredentials = internetCredentialsFromKeyChain(name: "LeafDriver", location: "be.oneclick.LeafDriver")
		let userName = userCredentials?.account ?? ""
		let password = userCredentials?.password ?? ""
		
		// Read te parameters from the Preferences…
		let settings = UserDefaults(suiteName: "be.oneclick.jan.LeafDriver")
		
		self.userSettings = UserSettings(
			userID: userName,
			clearPassWord: password,
			regionCode: settings?.string(forKey: "regionCode") ?? "",
			language: settings?.string(forKey: "language") ?? "",
			timeZone: settings?.string(forKey: "timeZone") ?? ""
		)
		
		self.restAPI = RestAPI(baseURL: leafProtocol.baseURL)
		
	}
	
	public typealias AnyLeafMethod = () -> Void
	public typealias LeafCommandMethodPair = (command:LeafCommand,method:AnyLeafMethod)
	public var commandQueue = Queue<LeafCommandMethodPair> ()
	
	public typealias LeafAPI = RestAPI
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
	
	
	var baseParameters:HTTPFormEncodable{
		get{
			BaseParameters(regionCode: session?.customerInfo.regionCode ?? "",
						   timeZone: session?.customerInfo.timezone ?? "",
						   language: session?.customerInfo.language ?? "",
						   customSessionID: session?.vehicleInfoList.vehicleInfoListVehicleInfo.first?.customSessionid ?? "",
						   vin: session?.vehicleInfoList.vehicleInfoListVehicleInfo.first?.vin ?? "",
						   dcmid: session?.vehicle.profile.dcmId ?? ""
			)
		}
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
				let connectParameters = ConnectParameters(initialAppStr: self.leafProtocol.initialAppString)
				self.connectionInfo = try await restAPI.decode(method:RestAPI.Method.POST, command: LeafCommand.connect, parameters: connectParameters, timeout: 30)
				connectionState = max(connectionState, .connected)
				logger.info("Leafdriver connected succesfully")
			} catch let error{
				handleLeafAPIError(error)
			}
			runCommandQueue()
		}
		
	}
	
	
	
	private func login(){
		
		Task{
			do {
				let loginParameters = LoginParameters(initialAppStr: leafProtocol.initialAppString,
													  userID: userSettings.userID,
													  encryptedPassWord: userSettings.encryptedPassWord(withKey: connectionInfo?.baseprm ?? ""),
													  regionCode: userSettings.regionCode,
													  timeZone: userSettings.timeZone,
													  language: userSettings.language
				)
				self.session = try await restAPI.decode(method:RestAPI.Method.POST, command: LeafCommand.login, parameters: loginParameters, timeout: 75)
				connectionState = max(connectionState, .loggedIn)
				logger.info("Leafdriver logged in succesfully")
			} catch let error{
				handleLeafAPIError(error)
			}
			runCommandQueue()
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
	
	internal func handleLeafAPIError(_ error: Error, for commandMethodPair: LeafCommandMethodPair? = nil) {
		
		switch error {
			default:
				connectionState = .disconnected
		}
		var errorMessage:String = ""
		if let commandMethodPair = commandMethodPair{
			errorMessage += "\(commandMethodPair.command.stringValue)\n"
			commandQueue.enqueue( commandMethodPair )
		}
		errorMessage += error.localizedDescription
		logger.error("\(errorMessage)")
	}
	
}
