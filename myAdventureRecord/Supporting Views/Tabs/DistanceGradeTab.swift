//
//  DistanceGradeTab.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/28/20.
//

import SwiftUI

struct DistanceGradeTab: View {
	var adventure : Adventure
	var body: some View {
		VStack (alignment: .center) {
			Text("Grade: \(adventure.name)")
			 HStack {
				Text(String(format: "Min Elevation: %5.2f", adventure.trackData.trackSummary.elevationStats.min.elevation*feetperMeter))
				Spacer()
				Text("Track points:  \(adventure.trackData.trkptsList.count)")
				Spacer()
				Text(String(format: "Max Elevation: %5.2f", adventure.trackData.trackSummary.elevationStats.max.elevation*feetperMeter))
			  }.padding(.horizontal)
			
			HStack {
				Group {
					Text("Slope Angles: ")
						.foregroundColor(Color.white)
					Text(String(format: "%2d°", -25))
						.foregroundColor(Color(NSColor.systemBlue))
					Spacer()
					Text(String(format: "%2d°", -10))
						.foregroundColor(Color(NSColor.systemPurple))
					Spacer()
					Text(String(format: "%2d°", -5))
						.foregroundColor(Color(NSColor.systemRed))
					Spacer()
					Text(String(format: "%2d°", 0))
						.foregroundColor(Color(NSColor.systemOrange))
				}
				Group {
					Spacer()
					Text(String(format: "%2d°", +5))
						.foregroundColor(Color(NSColor.systemYellow))
					Spacer()
					Text(String(format: "%2d°", +10))
						.foregroundColor(Color(NSColor.systemTeal))
					Spacer()
					Text(String(format: "%2d°", +25))
						.foregroundColor(Color(NSColor.systemIndigo))
				}
				
			}.padding(.horizontal)
			VStack {
					
				DistanceGradeChart(track: adventure.trackData)
				
					//.foregroundColor(Color.black)
					//.background(Color.yellow)
			}//.padding()

		}//.padding()
	}

}

struct DistanceGradeTab_Previews: PreviewProvider {
    static var previews: some View {
        DistanceGradeTab(adventure: adventureData[0])
    }
}
