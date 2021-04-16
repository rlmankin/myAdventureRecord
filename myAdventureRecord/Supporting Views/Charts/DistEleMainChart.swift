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
			ForEach( (1..<self.track.trkptsList.endIndex), id: \.self ) { item in
				let trkpt = self.track.trkptsList[item]
				Path { p in
					
					if (item == 1  || item == self.track.trkptsList.endIndex - 1 ) {
						timeStampLog(message: "\(readerHeight), \(item)")
					}
				//print("\(trkpt.index), \(reader.size.height), \(reader.size.width) \n")/*\t p \(p)  \n*/
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
				
				
				}.stroke(Color.yellow)
				 .offset(x: 30, y:0)
			}
	
		
		}//.background(Color.gray)
		
    }
}

//struct DistEleMainChart_Previews: PreviewProvider {
//    static var previews: some View {
//		DistEleMainChart( track: adventureData[0].trackData)
//    }
//}
