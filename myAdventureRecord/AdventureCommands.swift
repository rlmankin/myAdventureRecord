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
		CommandMenu("parse"){
			Button("Parse file") {
				
			}
			Button("Parse batch") {
				
			}
		}
		CommandMenu("dataBase") {
			Button("Insert Selected") {
				
			}
			Button("Insert All") {
				
			}
			
			Button(action: {
				print("List dB")
				}, label: {
					Text("list dB Button")
				}
			)
			
			
			
		}
		SidebarCommands()
		
	}
}

private struct ParseAdventureKey: FocusedValueKey {
	typealias Value = Binding<Adventure>
}

