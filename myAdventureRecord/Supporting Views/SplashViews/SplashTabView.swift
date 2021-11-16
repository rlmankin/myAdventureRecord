//
//  SplashTabView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 10/27/21.
//

import SwiftUI
import SigmaSwiftStatistics

struct SplashTabView: View {
	var filteredAdventures : [Double] = []
	var filteredAdventuresName : [String] = []
	
	
	
    var body: some View {
		VStack {
			GeometryReader { proxy in
				HStack {
					DescriptiveStatsView(filteredAdventures: filteredAdventures,
										 filteredAdventuresName: filteredAdventuresName)
						.frame(width: proxy.size.width * 0.4)
					
					
					DistributionChart(filteredAdventures: filteredAdventures)
				}
			}
		}
    }
}

struct SplashTabView_Previews: PreviewProvider {
    static var previews: some View {
		let arry = adventureData.filter({$0.hikeCategory == .hike})
		let arry1 = arry.compactMap({$0.distance / metersperMile})
		let arryName = arry.compactMap({$0.name})
        SplashTabView(filteredAdventures: arry1,
						filteredAdventuresName: arryName)
    }
}
