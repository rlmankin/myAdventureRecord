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
	
    var body: some View {
		NavigationView {
			
			List  {
				ForEach(userData.adventures) { adventure in
					NavigationLink(destination: AdventureDetail(adventure: adventure)) {
						AdventureRow(adventure: adventure)
					}
				}
			}.frame(width: 375)
			/*.toolbar {
				ToolbarItem {
					Menu {
						
					
					} label: {
						Label("toolbar filters?", systemImage: "slider.horizontal.3")
					}
				}*/
			}
   		 }
	}

struct AdventureList_Previews: PreviewProvider {
    static var previews: some View {
		AdventureList()
			.environmentObject(UserData())
    }
}
