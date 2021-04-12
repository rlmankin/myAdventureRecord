//
//  DistGrdMainChart.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 1/14/21.
//

import SwiftUI

struct DistGrdMainChart: View {
	var track: Track
	
	
	
	func calcLegDistance(_ index: Int) -> Double {
		return self.track.trkptsList[...index].compactMap({$0.lastTrkpt.distance}).reduce(0,+)
		
	}
	func rad2deg(_ number: Double) -> Double {
		return number * 180 / .pi
	}
	
	func setGradeColor(gain: Double, distance: Double) -> Color {
		guard distance != 0 else {return Color.yellow}
		//print("\(gain/distance)")
		switch gain/distance {
			
			case ..<(-0.176327): return Color(NSColor.systemBlue)
			case -0.176327..<(-0.0874887): return Color(NSColor.systemPurple)
			case -0.0874887..<(0.0): return Color(NSColor.systemRed)
			case 0.0..<(0.0874887): return Color(NSColor.systemOrange)
			case 0.0874887..<(0.17632698): return Color(NSColor.systemYellow)
			case 0.17632698...: return Color(NSColor.systemTeal)
		default: return Color(NSColor.systemIndigo)
		}
	}
	
	
	
	
		
		
	var body: some View {
		
		let verticalGridSpacing = 5.0		// every 5 meters (feet when converted - not implemented yet)
		let lowerGridPoint =  roundDowntoNearest(nearest: verticalGridSpacing, track.trackSummary.elevationStats.min.elevation)
		let upperGridPoint =  roundUptoNearest(nearest: verticalGridSpacing, track.trackSummary.elevationStats.max.elevation)
	
	
		let totalDistance = track.trackSummary.distance
	
		GeometryReader { reader in
		// elevation chart line
			ForEach( (1...self.track.trkptsList.count - 1), id: \.self ) { item in
				let trkpt = self.track.trkptsList[item]
				Path { p in
				let readerWidth = reader.size.width
					let readerHeight = reader.size.height
				
					let distWidth = distanceWidth(readerWidth, totalDistance)
					let yHeight = elevationHeight(readerHeight, upperGridPoint, lowerGridPoint)
					let prevlegDistance = calcLegDistance(item - 1)
							// self.trkptList[...(item - 1)].compactMap({$0.lastTrkpt.distance}).reduce(0,+)
					let currlegDistance = calcLegDistance(item)
							//self.trkptList[...(item)].compactMap({$0.lastTrkpt.distance}).reduce(0,+)
					let prevXOffset = distanceOffset(prevlegDistance, pixelPerMeter: distWidth)
					let prevYOffset = elevationOffset(self.track.trkptsList[ item - 1].elevation!, yHeight, lowerGridPoint)
					let xOffset = distanceOffset(currlegDistance, pixelPerMeter: distWidth)
					let currYOffset = elevationOffset(trkpt.elevation!, yHeight, lowerGridPoint)
					//print("\t \(distWidth), \(yHeight), \(xOffset), \(prevYOffset), \(currYOffset) \n")
					p.move(to: CGPoint(x: prevXOffset,
								   y: readerHeight - prevYOffset))
					p.addLine(to: CGPoint(x: xOffset,
									  y: readerHeight - currYOffset))
				
				}.stroke(setGradeColor(gain: trkpt.lastEleTrkpt.gain, distance: trkpt.lastEleTrkpt.distance),style: StrokeStyle(lineWidth: 2))
				.offset(x: 30, y:0)
			}
	
		
		}//.background(Color.gray)
		
	}
}

struct DistGrdMainChart_Previews: PreviewProvider {
    static var previews: some View {
		DistGrdMainChart(track: adventureData[0].trackData)
    }
}
