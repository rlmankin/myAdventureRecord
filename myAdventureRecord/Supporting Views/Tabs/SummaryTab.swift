//
//  SummaryTab.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 2/8/21.
//

import SwiftUI

struct SummaryTab: View {
	
	var adventure: Adventure
    var body: some View {
		ScrollView {
			Text(adventure.trackData.print())
				.font(.caption)
		}
    }
}

struct SummaryTab_Previews: PreviewProvider {
    static var previews: some View {
        SummaryTab(adventure: adventureData[0])
    }
}
