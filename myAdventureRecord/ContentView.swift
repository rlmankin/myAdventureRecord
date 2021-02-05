//
//  ContentView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 2/3/21.
//

import SwiftUI

struct ContentView: View {
	
	@State private var showDBTable = false
	
	var body: some View {
					
		if showDBTable {
			HikingDBView()
		} else {
			AdventureList()
			.frame(minWidth: 875, idealWidth: 900, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,  minHeight: 500, idealHeight: 900, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
		}
	}
}


struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		
			ContentView()
				.environmentObject(UserData())
			
		
	}
}
