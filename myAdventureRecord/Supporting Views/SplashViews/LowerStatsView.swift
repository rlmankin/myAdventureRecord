//
//  SplashTabsView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 10/31/21.
//

import SwiftUI

struct LowerStatsView: View {
	var filteredAdventures: [Adventure]
    var body: some View {
		TabView {
			SplashTabView(
				filteredAdventures:
					filteredAdventures.compactMap({$0.distance / metersperMile}),
				filteredAdventuresName:  filteredAdventures.compactMap({$0.name})
			).tabItem({		Image(systemName: "thermometer")
							Text("Distance (miles)")})//.background(Color.red)
			SplashTabView(
				filteredAdventures:
					filteredAdventures.compactMap({$0.trackData.trackSummary.totalAscent / feetperMeter}),
				filteredAdventuresName:  filteredAdventures.compactMap({$0.name})
			).tabItem({		Image(systemName: "thermometer")
							Text("Gain (feet)")})//.background(Color.red)
			
			SplashTabView(
			filteredAdventures:
				filteredAdventures.compactMap({$0.trackData.trackSummary.duration/secondsperHour}),
			filteredAdventuresName:  filteredAdventures.compactMap({$0.name})
			)
			.tabItem({		Image(systemName: "thermometer")
						Text("Duration (hours)")})//.background(Color.red)
			
		}
    }
}

struct SplashTabsView_Previews: PreviewProvider {
    static var previews: some View {
		LowerStatsView(filteredAdventures: adventureData)
    }
}
