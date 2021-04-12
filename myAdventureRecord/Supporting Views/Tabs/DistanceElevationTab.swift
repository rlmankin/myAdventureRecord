//
//  DistanceElevationTab.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/28/20.
//

import SwiftUI




struct DistanceElevationTab: View {
	
	var adventure : Adventure
    var body: some View {
		
		timeStampLog(message: "DistanceElevationTab")
		return VStack (alignment: .center) {
		 	Text("Elevations - \(adventure.name)")
			 HStack {
				Text(String(format: "Min Elevation: %5.2f", adventure.trackData.trackSummary.elevationStats.min.elevation*feetperMeter))
				Spacer()
				Text("Track points:  \(adventure.trackData.trkptsList.count)")
				Spacer()
				Text(String(format: "Max Elevation: %5.2f", adventure.trackData.trackSummary.elevationStats.max.elevation*feetperMeter))
			  }.padding(.horizontal)
			HStack {
				Text(String(format: "Total Ascent: %5.2f", adventure.trackData.trackSummary.totalAscent*feetperMeter))
				let hoursDuration = Int(adventure.trackData.trackSummary.duration / secondsperHour)
				let minutesDuration = Int((Double(adventure.trackData.trackSummary.duration/secondsperHour) - Double(hoursDuration))*60.0)
				Spacer()
				Text(String(format: " Total Duration - %3d:%2d", hoursDuration, minutesDuration))
				Spacer()
				Text(String(format: "Total Descent: %5.2f", -adventure.trackData.trackSummary.totalDescent*feetperMeter))
			}.padding(.horizontal)
			HStack {
				Text(String(format: "Max Grade: %2.2f%%", adventure.trackData.trackSummary.mileStats.grade.max.statData*100))
					.foregroundColor(Color.red)
				Spacer()
				Text(String(format: "Min Grade: %2.2f%%",
					-adventure.trackData.trackSummary.mileStats.grade.min.statData*100))
					.foregroundColor(Color.green)
				Spacer()
				Text(String(format: "Max speed: %2.2f mph", adventure.trackData.trackSummary.mileStats.speed.max.statData/metersperMile*secondsperHour))
					.foregroundColor(Color(NSColor.systemTeal))
				Spacer()
				Text(String(format: "Min Speed: %2.2f mph",
					-adventure.trackData.trackSummary.mileStats.speed.min.statData/metersperMile*secondsperHour))
					.foregroundColor(Color.orange)
			}.padding(.horizontal)
			VStack {
					
				DistanceElevationChart(track: adventure.trackData)
				
					//.foregroundColor(Color.black)
					//.background(Color.yellow)
			}//.padding()

		}//.padding()
    }
}

struct DistanceElevationTab_Previews: PreviewProvider {
    static var previews: some View {
        DistanceElevationTab(adventure: adventureData[0])
    }
}
