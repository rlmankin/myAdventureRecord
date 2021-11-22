//
//  UpperStatsView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 10/31/21.
//

import SwiftUI

struct UpperStatsView: View {
	var filteredAdventures : [Adventure]
    var body: some View {
		timeStampLog(message: "-> UpperStatsView")
		return
			VStack (alignment: .leading)  {
				VStack (alignment: .leading) {
					Text("Total Statistics")
						.font(.headline).bold().italic()
					Group {
						Text("# Adventures: \(filteredAdventures.count)")
						Text(String( format: "Distance: %5.2f miles", filteredAdventures.compactMap({$0.distance}).reduce(0,+) / metersperMile))
						Text(String( format: "Gain: %5.2f feet", filteredAdventures.compactMap({$0.trackData.trackSummary.totalAscent}).reduce(0,+) * feetperMeter))
						let duration = calcDaysHoursMinutes(seconds: filteredAdventures.compactMap({$0.trackData.trackSummary.duration}).reduce(0,+))
						Text(String(format: "Duration - %2dd %3dh %2dm", duration.days, duration.hours, duration.minutes))
						Text(String( format: "Max Elevation: %5.2f feet", filteredAdventures.compactMap({$0.trackData.trackSummary.elevationStats.max.elevation}).max()! * feetperMeter))
					}
					.font(.subheadline)
					.alignmentGuide(.leading, computeValue: {_ in -10})
				}.padding(.bottom)
		
				VStack (alignment: .leading) {
					Text(" Leaderboard")
						.font(.headline).bold().italic()
					Group {
						//  best distance
						VStack (alignment: .leading) {
							let max = filteredAdventures.compactMap({$0.distance}).max()!
							Text(String( format: "Longest Distance : %5.2f miles  ",  max / metersperMile))
							let index = filteredAdventures.firstIndex(where: {$0.distance == max})!
							Text("\t\(filteredAdventures[index].name)")
								.italic()
						}
						//	best gain
						VStack (alignment: .leading) {
							let max = filteredAdventures.compactMap({$0.trackData.trackSummary.totalAscent}).max()!
							Text(String( format: "Largest Gain : %5.2f feet:  ",  max * feetperMeter))
							let index = filteredAdventures.firstIndex(where: {$0.trackData.trackSummary.totalAscent == max})!
							Text("\t\(filteredAdventures[index].name)").italic()
						}
						//	best duration
						VStack (alignment: .leading) {
							let max = calcDaysHoursMinutes(seconds: filteredAdventures.compactMap({$0.trackData.trackSummary.duration}).max()!)
							Text(String( format: "Largest Duration : %5dh %2dm:  ",  max.hours, max.minutes))
							let index = filteredAdventures.firstIndex(where: {$0.trackData.trackSummary.duration == filteredAdventures.compactMap({$0.trackData.trackSummary.duration}).max()!})!
							Text("\t\(filteredAdventures[index].name)").italic()
						}
						//	best month
						let bestMonth = leaderBoardBestMonth(dateArray: filteredAdventures.compactMap({$0.hikeDate}))
						Text("Best Month: \(bestMonth.month) with \(bestMonth.count) adventures")
						
					}
					.font(.subheadline)
					.alignmentGuide(.leading, computeValue: {_ in -10})
				}.padding(.bottom)
			}.padding(5)
			.font(.callout)
    }
}

struct UpperStatsView_Previews: PreviewProvider {
    static var previews: some View {
        UpperStatsView(filteredAdventures: adventureData)
    }
}
