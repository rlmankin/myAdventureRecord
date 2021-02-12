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
	
	//@State private var selectedURL : URL = URL(string: "nofileselected")!
	@State private var tabcount: Int = 1
	@State private var selectedTab : Int = 1
	@State private var parseFile = false
	
	
    var body: some View {
		
		switch (showDBTable, parseFile) {
			case (false, false) :
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
						ToolbarItem(placement: .status) {
							Button("Parse") {
								parseFile.toggle()
								tabcount += 1
								selectedTab = tabcount
							}
						}
					 }
				}
			case (true, false) :
				HikingDBView()
				.toolbar {
					   ToolbarItem {
						   
						   Button("\(showDBTable == true ? "List" : "dbTable")") {
							   showDBTable.toggle()
						   }
					   
					   }
					}
			case (false, true) :
				GPXParsingView().toolbar {
					 ToolbarItem {
						Button("\(parseFile == true ? "List" : "Parse")") {
								parseFile.toggle()
						}
					
					}
				}
		
					
			
			
			case (true, true) : Text("Error (true,true)")
		
		
		}
		
	}
}

struct AdventureList_Previews: PreviewProvider {
    static var previews: some View {
		AdventureList()
			.environmentObject(UserData())
    }
}
