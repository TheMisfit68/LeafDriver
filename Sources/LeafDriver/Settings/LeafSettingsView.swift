//
//  LeafSettingsView.swift
//
//
//  Created by Jan Verrept on 08/11/2023.
//

import SwiftUI
import RegexBuilder
import JVSecurity
import JVUI
import JVSwiftCore

public struct LeafSettingsView: View, SettingsView, Securable {
	
	@State private var userName: String
	@State private var password: String
	
	@AppStorage("regionCode", store: UserDefaults(suiteName: "be.oneclick.jan.LeafDriver")) private var regionCode: String = Region.allCases[0].rawValue
	@AppStorage("language", store: UserDefaults(suiteName: "be.oneclick.jan.LeafDriver")) private var language: String = Language.allCases[0].rawValue
	@AppStorage("timeZone", store: UserDefaults(suiteName: "be.oneclick.jan.LeafDriver")) private var timeZone: String = TimeZone.allCases[0].rawValue
	
	public let notificationKey: String = "LeafDriverSettingsChanged"
	
	// An explicit public initializer
	public init() {
		_userName = State(initialValue: "")
		_password = State(initialValue: "")
	}
	
	
	public var body: some View {
		
		Form{
			UserCredentialsSection(userName: $userName, password: $password, onCommitMethod: self.onCommitMethod, notificationKey: self.notificationKey)
			
			Section(header: Label(String(localized: "Regional Settings", bundle:.module), systemImage: "globe")) {
				HStack {
					Text(String(localized: "Region Code", bundle:.module))
						.frame(width: 100, alignment: .trailing)
					Picker("", selection: $regionCode) {
						ForEach(Region.allCases, id: \.self) { item in
							Text(item.localizedDescription.capitalized)
								.tag(item.rawValue)
						}
					}
					.frame(width: 200)
					.pickerStyle(MenuPickerStyle())
					.onChange(of: regionCode) { newValue in postNotification() }
				}
				HStack {
					Text(String(localized: "Language", bundle:.module))
						.frame(width: 100, alignment: .trailing)
					Picker("", selection: $language) {
						ForEach(Language.allCases, id: \.self) { item in
							Text(item.localizedDescription.capitalized)
								.tag(item.rawValue)
						}
					}
					.frame(width: 200)
					.pickerStyle(MenuPickerStyle())
					.onChange(of: language) { newValue in postNotification() }
				}
				HStack {
					Text(String(localized: "Timezone", bundle:.module))
						.frame(width: 100, alignment: .trailing)
					Picker("", selection:$timeZone) {
						ForEach(TimeZone.allCases, id: \.self) { item in
							Text(item.localizedDescription.capitalized)
								.tag(item.rawValue)
						}
					}
					.frame(width: 200)
					.pickerStyle(MenuPickerStyle())
					.onChange(of: timeZone) { newValue in postNotification() }
				}
			}
		}
		.padding(25)
		.onAppear{
			onAppearMethod()
		}
	}
	
	private var serverAndLocation:(String,String){
		
		var server:String = "be.oneclick.LeafDriver"
		let location = LeafProtocolV2().baseURL
		let serverPattern = /https?:\/\/(?:www\.)?([^:\/\s]+)./.ignoresCase()
		if let match = location.firstMatch(of: serverPattern) {
			server = String(match.1)
		}
		return (server,location)
		
	}
	
	private func onAppearMethod(){
		if let userCredentials = internetCredentialsFromKeyChain(name: "LeafDriver", location: serverAndLocation.1){
			self.userName = userCredentials.account
			self.password = userCredentials.password
		}
	}
	
	private func onCommitMethod(){
		_ = storeInternetCredentialsInKeyChain(name: "LeafDriver", serverAndPort: (serverAndLocation.0, nil), location: serverAndLocation.1, account: self.userName, password: self.password)
	}
	
}


