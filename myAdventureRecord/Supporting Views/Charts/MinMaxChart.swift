//
//  MinMaxChart.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 1/12/21.
//

import SwiftUI



struct MinMaxChart: View {
	
	var track : Track
	var startIndex : Int
	var endIndex : Int
	var statData : Double
	var stringFormat : String
	var color : Color
	
	
	func calcLegDistance(_ index: Int) -> Double {
		return self.track.trkptsList[...index].compactMap({$0.lastTrkpt.distance}).reduce(0,+)
	}
	
	

    var body: some View {
		
		timeStampLog(message: "->MinMaxChart")
		let verticalGridSpacing = 5.0		// every 5 meters (feet when converted - not implemented yet)
		// localize all statistics in question
		//let startIndex = track.trackSummary.mileStats.grade.max.startIndex		// changes
		//let endIndex = track.trackSummary.mileStats.grade.max.endIndex			// changes
		//let statData = track.trackSummary.mileStats.grade.max.statData			// changes
		
		// determine the boundaries of what will be charted
		let totalDistance = track.trackSummary.distance
		let lowerGridPoint =  roundDowntoNearest(nearest: verticalGridSpacing, track.trackSummary.elevationStats.min.elevation)
		let upperGridPoint =  roundUptoNearest(nearest: verticalGridSpacing, track.trackSummary.elevationStats.max.elevation)
		
		// localize necessary start index calculations
		let startLegDistance = calcLegDistance(startIndex)
		let startPointElevation = track.trkptsList[startIndex].elevation!		// fix this force-unwrap
		let endLegDistance = calcLegDistance(endIndex)
		let endPointElevation = track.trkptsList[endIndex].elevation!		// fix this force-unwrap
		
		return GeometryReader { reader in
			let readerWidth = reader.size.width
			let readerHeight = reader.size.height
			// determine the grid distance for height and width of chart
			let yHeight = elevationHeight(readerHeight, upperGridPoint, lowerGridPoint)
			let distWidth = distanceWidth(readerWidth, totalDistance)
			
			// determine height and offset for the start/end index text information (i.e. statData)
			let startYHeight = elevationOffset(startPointElevation, yHeight, lowerGridPoint)
			let startXOffset = distanceOffset(startLegDistance, pixelPerMeter: distWidth)
			let endYHeight = elevationOffset(endPointElevation, yHeight, lowerGridPoint)
			let endXOffset = distanceOffset(endLegDistance, pixelPerMeter: distWidth)
			// draw the requested statData value
			Text(String(format: stringFormat, statData))
			  	.font(.footnote)
			   	.foregroundColor(color)
				.offset(x: startXOffset + 35,
						y: readerHeight - startYHeight)
			
			// determine the distance, gain values for GainTriangleView
			let distX = Double((endLegDistance - startLegDistance)/metersperMile)
			let distY = Double((endPointElevation - startPointElevation)*feetperMeter)
			GainTriangleView(readerHeight: readerHeight, startXOffset: startXOffset, endXOffset: endXOffset, startYHeight: startYHeight, endYHeight: endYHeight, distX: distX, distY: distY, color: color)
			
			// draw the line for the statistic in question
			if startIndex + 1 <= endIndex {
				ForEach ((startIndex + 1...endIndex) , id: \.self) { index in
					let trkpt = track.trkptsList[index]
					Path { p in
						// x-axis offsets
						let prevlegDistance = calcLegDistance(index - 1)
						let currlegDistance = calcLegDistance(index)
						let prevXOffset = distanceOffset(prevlegDistance, pixelPerMeter: distWidth)
						let xOffset = distanceOffset(currlegDistance, pixelPerMeter: distWidth)
						// y-axis offsets
						let prevYOffset = elevationOffset(self.track.trkptsList[ index - 1].elevation!, yHeight, lowerGridPoint)
						let currYOffset = elevationOffset(trkpt.elevation!, yHeight, lowerGridPoint)
						// move to the x,y location of the previous trkpt
						p.move(to: CGPoint(x: prevXOffset,
								   y: readerHeight - prevYOffset))
						// draw line to current trkpoint x,y location
						p.addLine(to: CGPoint(x: xOffset,
									  y: readerHeight - currYOffset))
					}.stroke(color,
							 style: StrokeStyle(lineWidth: 2))
					 .offset(x:30, y:0)
					
				}
			}
		}
    }
}

struct MinMaxChart_Previews: PreviewProvider {
    static var previews: some View {
		MinMaxChart(track: adventureData[0].trackData,
					startIndex: adventureData[0].trackData.trackSummary.mileStats.grade.max.startIndex,
					endIndex: adventureData[0].trackData.trackSummary.mileStats.grade.max.endIndex,
					statData: adventureData[0].trackData.trackSummary.mileStats.grade.max.statData*100,
					stringFormat: "%2.2f%%",
					color: Color.red)
		MinMaxChart(track: adventureData[0].trackData,
					startIndex: adventureData[0].trackData.trackSummary.mileStats.speed.min.startIndex,
					endIndex: adventureData[0].trackData.trackSummary.mileStats.speed.min.endIndex,
					statData: adventureData[0].trackData.trackSummary.mileStats.speed.min.statData/metersperMile*secondsperHour,
					stringFormat: "%1.2f",
					color: Color.green)
		MinMaxChart(track: adventureData[0].trackData,
					startIndex: adventureData[0].trackData.trackSummary.mileStats.grade.min.startIndex,
					endIndex: adventureData[0].trackData.trackSummary.mileStats.grade.min.endIndex,
					statData: adventureData[0].trackData.trackSummary.mileStats.grade.min.statData*100,
					stringFormat: "%2.2f%%",
					color: Color.blue)
    }
}
