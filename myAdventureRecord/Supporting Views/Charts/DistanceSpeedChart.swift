//
//  DistanceSpeedChart.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 1/13/21.
//

import SwiftUI

struct DistanceSpeedChart: View {
	var track: Track
    var body: some View {
		ZStack {
			GeometryReader { reader in
				
				DistSpdMainChart(track:track)
					.frame(width: reader.size.width - 30, height: reader.size.height - 30)
				
				XAxisView(track:track)
				.frame(width: reader.size.width - 30, height: reader.size.height)
				.offset(x:30)
				
				YAxisView(track: track,
						  verticalGridSpacing: 0.1,
							minValue: 0.0,
							maxValue:  track.trkptsList.compactMap({$0.lastTimeDistTrkpt.trailSpeed}).max()!/metersperMile*secondsperHour,
							metric2English: secondsperHour/metersperMile)
					.frame(height: reader.size.height - 30)
			}
		}
    }
}

struct DistanceSpeedChart_Previews: PreviewProvider {
    static var previews: some View {
		DistanceSpeedChart(track:adventureData[0].trackData)
    }
}
