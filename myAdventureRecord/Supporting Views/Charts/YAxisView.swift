//
//  XAxisView.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 1/5/21.
//

import SwiftUI
	


struct YAxisView: View {
	//var trkptList : [Trkpt]		// array of track elevations.  The relevant fields are .elevation?
									//	and lastTrkPt.distance
	var track : Track
	//var reader : GeometryProxy
	var verticalGridSpacing : Double
	var minValue : Double
	var maxValue : Double
	var metric2English : Double
	
	
	
	func calcLegDistance(_ index: Int) -> Double {
		return self.track.trkptsList[...index].compactMap({$0.lastTrkpt.distance}).reduce(0,+)	}
	
	
	var body: some View {
		
		
		timeStampLog(message: "->XAxisView")
		let readerScale =  CGFloat(1.0)
		// elevation grid computed properties
		//let verticalGridSpacing = 5.0		// every 5 meters (feet when converted - not implemented yet)
		let lowerGridPoint =  roundDowntoNearest(nearest: verticalGridSpacing, minValue)
		let upperGridPoint =  roundUptoNearest(nearest: verticalGridSpacing, maxValue)
		
		let verticalGridPoints  = createEleGridPoints(minEle: lowerGridPoint, maxEle: upperGridPoint, stepSize: verticalGridSpacing) // distance grid computed properties
		
		
		//  y-axis (elevation) Gridlines
		return //Group {
			GeometryReader { reader in
			//VStack {
			ForEach( verticalGridPoints, id: \.self) { elevation in
				let scaledReaderHeight = reader.size.height * readerScale
				let scaledReaderWidth = reader.size.width * readerScale
				//print("ele: \(elevation)")
				//Text("\(elevation)").offset(y:CGFloat(verticalGridPoints.firstIndex(of: elevation)!))
				
				Group {
					Path { p in
						
						let yHeight = elevationHeight(reader.size.height, upperGridPoint, lowerGridPoint)
						let y = reader.size.height - elevationOffset( elevation, yHeight, lowerGridPoint)
						p.move(to: CGPoint(x:30, y: y ))
						
						let modElevation = Int(round((elevation - lowerGridPoint)/verticalGridSpacing)) % 5
						if  modElevation == 0 {		// major Gridline
							p.addLine(to:CGPoint(x: reader.size.width, y:y))
						} else {
							p.addLine(to: CGPoint(x: 40, y:y))
							
						}
					}.stroke(Color(NSColor.systemGray), style: StrokeStyle(dash: [1]))		// dash value = length of dash in points
					if ((Int(round((elevation - lowerGridPoint)/verticalGridSpacing)) % 5 == 0 ) ||
						(elevation == verticalGridPoints.last)) {
						let y = CGFloat((elevation == verticalGridPoints.last) ? 0 : -10.0)
						Text(String(format: "%5.0f", elevation*metric2English))
							.font(.footnote)
							.foregroundColor(Color.white)
							.frame(width: 30, alignment: .leading)
							.offset(x:0, y: scaledReaderHeight -
											elevationOffset(elevation,
												elevationHeight(scaledReaderHeight, upperGridPoint, lowerGridPoint),
											  lowerGridPoint) + y)
							
					}
				}
			}
		//}
		}
		
		
	
	}
}

struct YAxisView_Previews: PreviewProvider {
    static var previews: some View {
		let adventureIndex = 5
		if adventureData[adventureIndex].trackData.trkptsList.isEmpty {
			adventureData[adventureIndex].trackData.trkptsList = sqlHikingData.sqlRetrieveTrkptlist(adventureData[adventureIndex].id)				//	retrieve the trackspoint list from the trackpointlist table in the database
		}
		
		return  Group {
        YAxisView(track: adventureData[adventureIndex].trackData,
				  verticalGridSpacing: 5.0,
				  minValue: adventureData[5].trackData.trackSummary.elevationStats.min.elevation,
				  maxValue: adventureData[5].trackData.trackSummary.elevationStats.max.elevation,
				  metric2English: feetperMeter)
		
		YAxisView(track: adventureData[adventureIndex].trackData,
				  verticalGridSpacing: 0.1,
				  minValue: 0.0,
				  maxValue: adventureData[5].trackData.trackSummary.mileStats.speed.max.statData/metersperMile*secondsperHour,
				  metric2English: secondsperHour/metersperMile)
    }
	}
}
