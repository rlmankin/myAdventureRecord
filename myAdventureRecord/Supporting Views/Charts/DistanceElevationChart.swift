//
//  DistanceElevationChart.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/28/20.
//

import SwiftUI

struct DistanceElevationChart: View {
	
	
	var track : Track
	
	var body: some View {
	
		
		
		ZStack (alignment: .topLeading) {
		
			GeometryReader { reader in
				if reader.size.height != 0.0 {	// when GeometryReader iterates, sometime reader.size.height is - which
												//	causes a runtime warning on the frame because of a negative height.
												//	That warning is not fatal, but just want to get rid of it.
					DistEleMainChart(track: track)
						.frame(width: reader.size.width - 30, height: reader.size.height - 30)
					MinMaxChart(track:track,
								startIndex: track.trackSummary.mileStats.grade.max.startIndex,
								endIndex: track.trackSummary.mileStats.grade.max.endIndex,
								statData: track.trackSummary.mileStats.grade.max.statData*100,
								stringFormat: "%2.2f%%",
								color: Color.red)
						.frame(width: reader.size.width - 30, height: reader.size.height - 30)
					MinMaxChart(track:track,
								startIndex: track.trackSummary.mileStats.grade.min.startIndex,
								endIndex: track.trackSummary.mileStats.grade.min.endIndex,
								statData: -track.trackSummary.mileStats.grade.min.statData*100,
								stringFormat: "%2.2f%%",
								color: Color.green)
						.frame(width: reader.size.width - 30, height: reader.size.height - 30)
					MinMaxChart(track:track,
								startIndex: track.trackSummary.mileStats.speed.max.startIndex,
								endIndex: track.trackSummary.mileStats.speed.max.endIndex,
								statData: track.trackSummary.mileStats.speed.max.statData/metersperMile*secondsperHour,
								stringFormat: "%1.2f",
								color: Color(NSColor.systemTeal))
						.frame(width: reader.size.width - 30, height: reader.size.height - 30)
					MinMaxChart(track:track,
								startIndex: track.trackSummary.mileStats.speed.min.startIndex,
								endIndex: track.trackSummary.mileStats.speed.min.endIndex,
								statData: track.trackSummary.mileStats.speed.min.statData/metersperMile*secondsperHour,
								stringFormat: "%1.2f",
								color: Color.orange)
						.frame(width: reader.size.width - 30, height: reader.size.height - 30)
					YAxisView(track: track,
							  verticalGridSpacing: 5.0,
							  minValue: track.trackSummary.elevationStats.min.elevation,
							  maxValue: track.trackSummary.elevationStats.max.elevation,
							  metric2English: feetperMeter)
						.frame(height: reader.size.height - 30)
					XAxisView(track: track)
						.frame(width: reader.size.width - 30, height: reader.size.height)
						.offset(x:30)
				}
			}
			
			
		}
    }
}

struct DistanceElevationChart_Previews: PreviewProvider {
    static var previews: some View {
		DistanceElevationChart(track: adventureData[0].trackData)
    }
}
