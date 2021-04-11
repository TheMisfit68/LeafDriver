//
//  LeafPreferences.swift
//  
//
//  Created by Jan Verrept on 06/04/2021.
//

import Foundation
import JVCocoa

extension LeafDriver:PreferenceBased {

	public enum PreferenceKey:String, StringRepresentableEnum{
		
		case leafSettings
		
		case initialAppStr
		case username
		case password
		case regionCode
		case language
		case timeZone
				
	}
		
	public var preferences:[LeafParameter:String]{
		
		var preferences:[LeafParameter:String] = [:]
		
		preferences[.userID] = getPreference(forKeyPath: .leafSettings, .username) ?? "myUserName"
		preferences[.clearPassword] = getPreference(forKeyPath: .leafSettings, .password) ?? "myClearPassword"
		preferences[.regionCode] = getPreference(forKeyPath: .leafSettings, .regionCode) ?? Region.europe.rawValue
		preferences[.language] = getPreference(forKeyPath: .leafSettings, .language) ?? Language.flemish.rawValue
		preferences[.timeZone] = getPreference(forKeyPath: .leafSettings, .timeZone) ?? TimeZone.brussels.rawValue
		
		return preferences
	}
	
}
