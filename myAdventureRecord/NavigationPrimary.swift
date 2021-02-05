//
//  NavigationPrimary.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/13/20.
//

import SwiftUI

struct NavigationPrimary: View {
	@Binding var selectedAdventure: Adventure?
	
	var body: some View {
		VStack {
			
			AdventureList()
		}
	}
}

struct NavigationPrimary_Previews: PreviewProvider {
    static var previews: some View {
        NavigationPrimary(selectedAdventure:
			.constant(adventureData[1]))
			.environmentObject(UserData())
    }
}
