//
//  AdventureList.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/10/20.
//

import SwiftUI

struct AdventureList: View {
	@EnvironmentObject private var userData: UserData
	@State private var selectedAdventure: Adventure?
	@State private var showDBTable = false
	
    var body: some View {
		if showDBTable {
			
			HikingDBView()
				.toolbar {
					ToolbarItem {
						
						Button("\(showDBTable == true ? "List" : "dbTable")") {
							showDBTable.toggle()
						}
					
					}
				 }
			
			
		} else {
			NavigationView {
				List  {
					ForEach(userData.adventures) { adventure in
						NavigationLink(destination: AdventureDetail(adventure: adventure)) {
							AdventureRow(adventure: adventure)
						}.tag(adventure)				}
				}
				.toolbar {
					ToolbarItem {
						
						Button("\(showDBTable == true ? "List" : "dbTable")") {
							showDBTable.toggle()
						}
					
					}
   				 }
			}
		}
	}
}

struct AdventureList_Previews: PreviewProvider {
    static var previews: some View {
		AdventureList()
			.environmentObject(UserData())
    }
}
