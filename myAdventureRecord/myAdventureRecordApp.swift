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
	
	var body: some Scene {
		WindowGroup {
			ContentView().environmentObject(userData)
						 .environmentObject(parseGPX)
		}
		.commands {
			AdventureCommands()
		}
	
	//var body: some Scene {
    //    let mainWindow = WindowGroup {
	//		ContentView().environmentObject(userData)
   //     }
    }
}
