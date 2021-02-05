//
//  DistanceSpeedTab.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/28/20.
//

import SwiftUI

struct DistanceSpeedTab: View {
	var adventure : Adventure
	var body: some View {
		VStack (alignment: .center) {
			Text("Speed - \(adventure.name)")
			 HStack {
				Text(String(format: "Min Speed (mile): %5.2f", adventure.trackData.trackSummary.mileStats.speed.min.statData/metersperMile*secondsperHour))
				Spacer()
				Text("Track points:  \(adventure.trackData.trkptsList.count)")
				Spacer()
				Text(String(format: "Max Speed (mile): %5.2f", adventure.trackData.trackSummary.mileStats.speed.max.statData * secondsperHour/metersperMile))
			  }.padding(.horizontal)
			
			VStack {
					
				DistanceSpeedChart(track: adventure.trackData)
				
					//.foregroundColor(Color.black)
					//.background(Color.yellow)
			}//.padding()

		}//.padding()
	}
}

struct DistanceSpeedTab_Previews: PreviewProvider {
    static var previews: some View {
        DistanceSpeedTab(adventure: adventureData[0])
    }
}
