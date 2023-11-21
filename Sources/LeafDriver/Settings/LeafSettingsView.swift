//
//  LeafSettingsView.swift
//
//
//  Created by Jan Verrept on 08/11/2023.
//

import SwiftUI
import JVCocoa

public struct LeafSettingsView: View, SettingsView, Securable {
    
    public let notificationKey: String = "LeafSettingsChanged"
    
    @State var userName: String = ""
    @State var passWord: String = ""
    
    public init(){}
    
    @AppStorage("regionCode", store: UserDefaults(suiteName: "be.oneclick.jan.LeafDriver")) var regionCode: String = Region.allCases[0].rawValue
    @AppStorage("language", store: UserDefaults(suiteName: "be.oneclick.jan.LeafDriver")) var language: String = Language.allCases[0].rawValue
    @AppStorage("timeZone", store: UserDefaults(suiteName: "be.oneclick.jan.LeafDriver")) var timeZone: String = TimeZone.allCases[0].rawValue
    
    public var body: some View {
        
        Form{
            Section(header: Label(String(localized: "Account",bundle: .module), systemImage: "person.fill")) {
                HStack {
                    Text(String(localized: "Username", bundle:.module))
                        .frame(alignment: .trailing)
                    TextField("", text: $userName, onCommit:{
                        _ = storePasswordInKeyChain(name:"LeafDriver", account: userName, location: "be.oneclick.LeafDriver", passWord: passWord)
                    })
                    .frame(width: 250, alignment: .trailing)
                }
                HStack {
                    Text(String(localized: "Password", bundle:.module))
                        .frame(width: 100, alignment: .trailing)
                    SecureField("", text: $passWord, onCommit: {
                        _ = storePasswordInKeyChain(name:"LeafDriver", account: userName, location: "be.oneclick.LeafDriver", passWord: passWord)
                    })
                    .frame(width: 250, alignment: .trailing)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
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
                    .onChange(of: timeZone) { newValue in postNotification() }
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
                    .onChange(of: timeZone) { newValue in postNotification() }
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
        .padding(5)
        .onAppear{
            // Should use this to intialise @State properties
            if let storedUserName = accountFromKeyChain(name:"LeafDriver", location: "be.oneclick.LeafDriver") {
                self.userName = storedUserName
                
                if let storedPassword = passwordFromKeyChain(name:"LeafDriver", account:self.userName, location: "be.oneclick.LeafDriver"){
                    self.passWord = storedPassword
                }
                
            }
        }
    }
}



// Preview code remains unchanged
#Preview {
    LeafSettingsView()
}
