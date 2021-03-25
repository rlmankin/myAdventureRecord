//
//  DistSpdMainChart.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 1/13/21.
//

import SwiftUI

struct DistSpdMainChart: View {
	var track: Track
	
	func calcLegDistance(_ index: Int) -> Double {
		return self.track.trkptsList[...index].compactMap({$0.lastTrkpt.distance}).reduce(0,+)
		
	}
	
	
	var body: some View {
		
	
		
		let verticalGridSpacing = 0.5		// every 5 mps (feet when converted - not implemented yet)
		let lowerGridPoint =  0.0
		//let upperGridPoint =  roundUptoNearest(nearest: verticalGridSpacing, track.trackSummary.mileStats.speed.max.statData)
		let upperGridPoint =  roundUptoNearest(nearest: verticalGridSpacing,
											   track.trkptsList.compactMap({$0.lastTimeDistTrkpt.trailSpeed}).max()!)
		//Text("\(lowerGridPoint), \(upperGridPoint)")


		let totalDistance = track.trackSummary.distance
		
		
		GeometryReader { reader in
		// elevation chart line
			
			ForEach( (1...self.track.trkptsList.count - 1), id: \.self ) { item in
				let trkpt = self.track.trkptsList[item]
				Path { p in
				//print("\(trkpt.index), \(reader.size.height), \(reader.size.width) \n")/*\t p \(p)  \n*/
					let readerWidth = reader.size.width
					let readerHeight = reader.size.height
			
					let distWidth = distanceWidth(readerWidth, totalDistance)
					let yHeight = elevationHeight(readerHeight, upperGridPoint, lowerGridPoint)
					let currlegDistance = calcLegDistance(item)
						//self.trkptList[...(item)].compactMap({$0.lastTrkpt.distance}).reduce(0,+)
					let xOffset = distanceOffset(currlegDistance, axisWidth: distWidth)
					let currYOffset = elevationOffset(trkpt.lastTimeDistTrkpt.trailSpeed, yHeight, lowerGridPoint)
					//print("\t \(distWidth), \(yHeight), \(xOffset), \(prevYOffset), \(currYOffset) \n")
					p.move(to: CGPoint(x: xOffset,
								   y: readerHeight))
					p.addLine(to: CGPoint(x: xOffset,
									  y: readerHeight - currYOffset))
			
				}.stroke(Color.yellow, style: StrokeStyle(lineWidth: 2))
					.offset(x: 30, y:0)
				//Text("\(trkpt.lastTimeDistTrkpt.trailSpeed)").offset(y:CGFloat(10*item))
			}

		}
	
	}
}

struct DistSpdMainChart_Previews: PreviewProvider {
    static var previews: some View {
        DistSpdMainChart(track: adventureData[0].trackData)
    }
}
