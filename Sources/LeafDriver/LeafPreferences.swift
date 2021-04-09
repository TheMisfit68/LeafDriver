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
		
		preferences[.userID] = getPreference(forKey: .leafSettings, secondaryKey: .username) ?? "myUserName"
		preferences[.clearPassword] = getPreference(forKey: .leafSettings, secondaryKey: .password) ?? "myClearPassword"
		preferences[.regionCode] = getPreference(forKey: .leafSettings, secondaryKey: .regionCode) ?? Region.europe.rawValue
		preferences[.language] = getPreference(forKey: .leafSettings, secondaryKey: .language) ?? Language.flemish.rawValue
		preferences[.timeZone] = getPreference(forKey: .leafSettings, secondaryKey: .timeZone) ?? TimeZone.brussels.rawValue
		
		return preferences
	}
	
}
