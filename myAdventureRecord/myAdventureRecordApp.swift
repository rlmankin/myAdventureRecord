//
//  myAdventureRecordApp.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 2/3/21.
//

import SwiftUI

@main
struct myAdventureRecordApp: App {
	@StateObject private var userData = UserData()
	@StateObject private var parseGPX = parseController()
	//@StateObject private var bpFiles = BPFiles()
	
	var body: some Scene {
		
		
		timeStampLog(message: "-> myApp")
		return WindowGroup {
			ContentView().environmentObject(userData)
						 .environmentObject(parseGPX)
		}
		.commands {
			AdventureCommands(stateFlag: .constant(FlagStates.empty))
		}
    }
}
