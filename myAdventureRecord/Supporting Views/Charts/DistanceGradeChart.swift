//
//  DistanceGradeChart.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 1/14/21.
//

import SwiftUI

struct DistanceGradeChart: View {
	var track : Track
	
    var body: some View {
		GeometryReader { reader in
			if reader.size.height != 0.0 {	// when GeometryReader iterates, sometime reader.size.height is - which
											//	causes a runtime warning on the frame because of a negative height.
											//	That warning is not fatal, but just want to get rid of it.
				DistGrdMainChart(track: track)
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

struct DistanceGradeChart_Previews: PreviewProvider {
    static var previews: some View {
		DistanceGradeChart(track: adventureData[0].trackData)
    }
}
