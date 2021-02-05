//
//  File.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 2/4/21.
//

import SwiftUI


struct AdventureCommands : Commands {
	private struct MenuInsert: View {
		
		var body: some View {
			HikingDBView()
		}
	}
	@State var dbListShowing : Bool = false
	
	var body: some Commands {
		CommandGroup(replacing: CommandGroupPlacement.newItem ) {
			Button("Parse") {
				
			}
		}
		CommandMenu("dataBase") {
			Button("Insert Selected") {
				
			}
			Button("Insert All") {
				
			}
			Button("List dB") {
				dbListShowing.toggle()
			}
			
			
		}
		SidebarCommands()
		
	}
}

private struct ParseAdventureKey: FocusedValueKey {
	typealias Value = Binding<Adventure>
}

