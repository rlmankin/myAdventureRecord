//
//  XAxisView.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 1/6/21.
//

import SwiftUI

struct XAxisView: View {
	//var trkptList : [Trkpt]		// array of track elevations.  The relevant fields are .elevation?
									//	and lastTrkPt.distance
	var track : Track
	//var reader : GeometryProxy
	
	
	
	func createXaxisGridPoints( minValue: Double, maxValue: Double, stepSize: Double) -> [Double] {
		var gridLine : [Double] = []
		var i = minValue
		while ( i <= maxValue) {
			gridLine.append(i)
			i += Double(stepSize)
		}
		return gridLine
	}
	
	
	func calcLegDistance(_ index: Int) -> Double {
		return self.track.trkptsList[...index].compactMap({$0.lastTrkpt.distance}).reduce(0,+)	}
	
	
	
	var body: some View {
		
		
		timeStampLog(message: "->YAxisView")
		
		
		let horizontalGridSpacing = Double(0.125*metersperMile) //0.125*metersperMile //0.25*1000	// every 1/4 kilometer (mile when converted - not implemented yet_
		let totalDistance = track.trkptsList.compactMap({$0.lastTrkpt.distance}).reduce(0,+)
		let rightGridpoint = Double(totalDistance)
		let horizontalGridPoints = createXaxisGridPoints(minValue: 0.0, maxValue: rightGridpoint, stepSize: horizontalGridSpacing)
		let readerScale =  CGFloat(1.0)
		//  y-axis (elevation) Gridlines
		
		return
			GeometryReader { reader in
			let scaledReaderHeight = reader.size.height * readerScale
			let scaledReaderWidth = reader.size.width * readerScale
			
			ForEach (horizontalGridPoints, id: \.self) { distance in
				let distWidth = distanceWidth(scaledReaderWidth, totalDistance)	// pixel per unit distance (e.g. pixel/meter)
				let xOffset = distanceOffset(distance, pixelPerMeter: distWidth)	
				let modDistance =  Int(round(distance/horizontalGridSpacing)) % 4
				Path { p in
					
					p.move(to: CGPoint(x: xOffset, y: scaledReaderHeight-30))
					if modDistance == 0 {
						p.addLine(to: CGPoint(x:xOffset, y:0))
					} else {
						p.addLine(to: CGPoint(x:xOffset, y:scaledReaderHeight-40))
						
					}
					//print("dist =\(distance), xoffset = \(xOffset)")
				}.stroke(Color.gray, style: StrokeStyle(dash: [5]))
				
				if ((modDistance == 0) || (distance == horizontalGridPoints.last)) {
					Text(String(format: "%3.3f", distance/metersperMile))
						.font(.footnote)
						.foregroundColor(Color.white)
						.frame(alignment: .trailing)
						.rotationEffect(.degrees(-45))						
						.offset(x: xOffset-22, y: reader.size.height-25)
				}
					
				
			}//.offset(x:0, y:0)
		}
		
	
	}
}

//struct XAxisView_Previews: PreviewProvider {
//    static var previews: some View {
//		XAxisView(track: adventureData[1].trackData)
//    }
//}
