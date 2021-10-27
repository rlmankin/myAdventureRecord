//
//  SplashView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 10/25/21.
//

import SwiftUI
import SigmaSwiftStatistics
 
func calcDaysHoursMinutes(seconds: Double) -> (days: Int, hours: Int, minutes: Int) {
	let secondsperDay = secondsperHour * 24.0 // 86400
	let days = seconds/secondsperDay
	let hours = days.truncatingRemainder(dividingBy: 1.0)*24
	let minutes = hours.truncatingRemainder(dividingBy: 1.0)*60
	return(Int(days), Int(hours), Int(minutes))
	
}

struct SplashView: View {
	
	
	var filteredAdventures : [Adventure] = adventureData
	
    var body: some View {
		VStack {
			VStack {
				Text("Total Stats")
				Text(String( format: "Distance: %5.2f miles", filteredAdventures.compactMap({$0.distance}).reduce(0,+) / metersperMile))
				Text(String( format: " Gain: %5.2f feet", filteredAdventures.compactMap({$0.trackData.trackSummary.totalAscent}).reduce(0,+) * feetperMeter))
				let duration = calcDaysHoursMinutes(seconds: filteredAdventures.compactMap({$0.trackData.trackSummary.duration}).reduce(0,+))
				Text(String(format: "Duration - %2dd %3dh %2dm", duration.days, duration.hours, duration.minutes))
				Text(String( format: "Max Elevation: %5.2f feet", filteredAdventures.compactMap({$0.trackData.trackSummary.elevationStats.max.elevation}).max()! * feetperMeter))
			}.padding(10)
		
			VStack {
				Text(" Leaderboard")
				HStack (alignment: .center) {
					Spacer()
					let max = filteredAdventures.compactMap({$0.distance}).max()!
					Text(String( format: "Longest Distance : %5.2f miles",  max / metersperMile))
					Spacer()
					let index = filteredAdventures.firstIndex(where: {$0.distance == max})!
					Text("\t\t\(filteredAdventures[index].name)")
					Spacer()
				}
				HStack {
					Spacer()
					let max = filteredAdventures.compactMap({$0.trackData.trackSummary.totalAscent}).max()!
					Text(String( format: "Largest Gain : %5.2f feet",  max * feetperMeter))
					let index = filteredAdventures.firstIndex(where: {$0.trackData.trackSummary.totalAscent == max})!
					Spacer()
					Text("\t\t\(filteredAdventures[index].name)")
					Spacer()
				}
				
				
				HStack {
					let max = calcDaysHoursMinutes(seconds: filteredAdventures.compactMap({$0.trackData.trackSummary.duration}).max()!)
					Text(String( format: "Largest Duration : %5dh %2dm",  max.hours, max.minutes))
					let index = filteredAdventures.firstIndex(where: {$0.trackData.trackSummary.duration == filteredAdventures.compactMap({$0.trackData.trackSummary.duration}).max()!})!
					Text("\(filteredAdventures[index].name)")
				}
				
			}.padding(10)
			
			
			TabView {
				SplashTabView(
					filteredAdventures:
						filteredAdventures.compactMap({$0.distance / metersperMile}),
					filteredAdventuresName:  filteredAdventures.compactMap({$0.name})
				).tabItem({		Image(systemName: "thermometer")
								Text("Distance (miles)")})//.background(Color.red)
				SplashTabView(
					filteredAdventures:
						filteredAdventures.compactMap({$0.trackData.trackSummary.totalAscent}),
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
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
		SplashView(filteredAdventures: adventureData )
    }
}
