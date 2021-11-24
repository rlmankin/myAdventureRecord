//
//  DistEleMainChart.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 1/11/21.
//

import SwiftUI

struct DistEleMainChart: View {
	
	var track: Track
	var reader : GeometryProxy
	
	
	
	func calcLegDistance(_ index: Int) -> Double {
		return self.track.trkptsList[...index].compactMap({$0.lastTrkpt.distance}).reduce(0,+)	}
	
	//Duplicate: original found in DistGrdMainChart
	func setGradeColor(gain: Double, distance: Double) -> Color {
		guard distance != 0 else {return Color.yellow}
		//print("\(gain/distance)")
		switch abs(gain/distance) {
			case 0.0..<(0.03): return Color(NSColor.systemGreen)
			case 0.03..<(0.05): return Color(NSColor.systemYellow)
			case 0.05..<(0.07): return Color(NSColor.systemOrange)
			case 0.07..<(0.09): return Color(NSColor.systemRed)
			case 0.09..<(0.20): return Color(NSColor.systemPurple)
			case 0.20..<(0.35): return Color(NSColor.systemBlue)
			case 0.35..<(0.50): return Color(NSColor.systemIndigo)
			default: return Color(NSColor.black)
		}
	}
	
	
		
		
    var body: some View {
		
		timeStampLog(message: "-> DistEleMainChart")
		let verticalGridSpacing = 5.0		// every 5 meters (feet when converted - not implemented yet)
		let lowerGridPoint =  roundDowntoNearest(nearest: verticalGridSpacing, track.trackSummary.elevationStats.min.elevation)
		let upperGridPoint =  roundUptoNearest(nearest: verticalGridSpacing, track.trackSummary.elevationStats.max.elevation)
	
	
		let totalDistance = track.trackSummary.distance
	
		return Group {
			
			//GeometryReader { reader in
			// elevation chart line
			let readerWidth = reader.size.width
			let readerHeight = reader.size.height
		
			let distWidth = distanceWidth(readerWidth, totalDistance)			// pixel per meter
			let yHeight = elevationHeight(readerHeight, upperGridPoint, lowerGridPoint)	// pixel per meter
			
			//let gainArray = self.track.trkptsList.compactMap({$0.lastTimeEleTrkpt.grade})
			ForEach( (1..<self.track.trkptsList.endIndex), id: \.self ) { item in
				
				//print("\(trkpt.index), \(reader.size.height), \(reader.size.width) \n")/*\t p \(p)  \n*/
				let prevlegDistance = calcLegDistance(item - 1)
						// self.trkptList[...(item - 1)].compactMap({$0.lastTrkpt.distance}).reduce(0,+)
				let currlegDistance = calcLegDistance(item)
						//self.trkptList[...(item)].compactMap({$0.lastTrkpt.distance}).reduce(0,+)
				let prevXOffset = distanceOffset(prevlegDistance, pixelPerMeter: distWidth)
				let prevYOffset = elevationOffset((self.track.trkptsList[ item - 1].elevation!),
										elevationHeight(readerHeight, upperGridPoint, lowerGridPoint), lowerGridPoint)
				let xOffset = distanceOffset(currlegDistance, pixelPerMeter: distWidth)
				let currYOffset = elevationOffset((self.track.trkptsList[ item].elevation!),
												  elevationHeight(readerHeight, upperGridPoint, lowerGridPoint), lowerGridPoint)
				//print("\t \(distWidth), \(yHeight), \(xOffset), \(prevYOffset), \(currYOffset) \n")
				
				let trkpt = self.track.trkptsList[item]
				let grade = trkpt.lastTimeEleTrkpt.grade
				
				let gradeColor = setGradeColor(gain: trkpt.lastTimeEleTrkpt.gain, distance: trkpt.lastTimeEleTrkpt.distance)
				
				Path { p in
					
					if (item == 1  || item == self.track.trkptsList.endIndex - 1 ) {
						timeStampLog(message: "\(readerHeight), \(item)")
					}
					p.move(to: CGPoint(x: prevXOffset,
								   y: readerHeight - prevYOffset))
					p.addLine(to: CGPoint(x: xOffset,
									  y: readerHeight - currYOffset))
				}.stroke(Color.yellow)
				
				// adds a line to the graph colored to represent the  grade of the segment.  This drives too much granularity in the graph,  need an alternate
				//		probably based on the 1/8m splits or 1m splits
				/*
				Path { p in
					p.move(to: CGPoint(x: xOffset,
									   y: readerHeight))
					p.addLine(to: CGPoint(x: xOffset,
										  y: readerHeight - currYOffset))
				}.stroke(gradeColor)
				*/
			}
	
		
		}//.background(Color.gray)
		
    }
}

struct DistEleMainChart_Previews: PreviewProvider {
    static var previews: some View {
	let adventureIndex = 5
	if adventureData[adventureIndex].trackData.trkptsList.isEmpty {
			  adventureData[adventureIndex].trackData.trkptsList = sqlHikingData.sqlRetrieveTrkptlist(adventureData[adventureIndex].id)				//	retrieve the trackspoint list from the trackpointlist table in the database
		  }
		  
		return GeometryReader { reader in
			DistEleMainChart( track: adventureData[adventureIndex].trackData, reader: reader)
		}
	}
}
