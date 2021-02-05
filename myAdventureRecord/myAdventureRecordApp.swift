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
	
	var body: some Scene {
		WindowGroup {
			ContentView().environmentObject(userData)
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
