//
//  SplitsView.swift.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 11/23/21.
//

import SwiftUI
import MapKit

struct SplitsView: View {
	var eighthSplits = [SplitStruct]()
	var mileSplits = [SplitStruct]()
	var textString : String = nullString
	let fixedLength : Int = 8
	let mileSpeedWidth : CGFloat = 120
	let barWidth : CGFloat = 280
	let gainGradeWidth : CGFloat = 150
	
	func padStringWithFormat(value : Double, format: String) -> String {
//let firstPercent = format.firstIndex(of: "%")!
		//let firstDot = format.firstIndex(of: ".")!
		//let valueSubstr  = String(value)[...firstDot]
		var formattedValue = String(format: format, value)
		let stringLength : Int = formattedValue.count
		
		
		if stringLength <= fixedLength {
			formattedValue = String(repeating: " ", count: fixedLength - stringLength) + formattedValue
		}
		return formattedValue
	}
	
	var body: some View {
		
		let max8thSpeed = eighthSplits.compactMap({$0.avgSpeed}).max()!
		let maxMileSpeed = mileSplits.compactMap({$0.avgSpeed}).max()!
		let maxSpeed = max(max8thSpeed, maxMileSpeed)
		VStack  {
			
				List {
					ForEach (0 ..< eighthSplits.endIndex, id: \.self) {index in
						HStack {
							HStack {
								Text(padStringWithFormat(value: Double(index), format: "%3.0f"))
								 /*
									Text(String(format: ", [%3.0d, %3.0d.distance = %3.2f]",
											eighthSplits[index].startIndex,
											eighthSplits[index].endIndex,
											eighthSplits[index].distance / metersperMile))
								 */
								Text( padStringWithFormat( value: eighthSplits[index].avgSpeed / metersperMile*secondsperHour, format: "%3.1f"))
							}
								.frame(width: mileSpeedWidth)
							
							//SplitsChartView(avgSpeed: eighthSplits[index].avgSpeed / metersperMile*secondsperHour, maxSpeed: maxSpeed)
							let barRatio = (eighthSplits[index].avgSpeed / maxSpeed) * barWidth
							Rectangle()
								.fill(.white)
								.frame(width: barRatio)
							Rectangle()
								.fill(.clear)
								.frame(width: barWidth - barRatio)
							HStack  {
								Text(padStringWithFormat(value: eighthSplits[index].gain * feetperMeter, format: "%5.1f"))
								Text(padStringWithFormat( value: eighthSplits[index].grade*100, format: "%3.1f"))
							}.frame(width: gainGradeWidth)
							
						}
							
							
					} // ForEach
					
					ForEach (0 ..< mileSplits.endIndex, id: \.self) {index in
						HStack {
							HStack {
								Text(padStringWithFormat(value: Double(index), format: "%3.0f"))
								 /*
									Text(String(format: ", [%3.0d, %3.0d.distance = %3.2f]",
											eighthSplits[index].startIndex,
											eighthSplits[index].endIndex,
											eighthSplits[index].distance / metersperMile))
								 */
								Text( padStringWithFormat( value: mileSplits[index].avgSpeed / metersperMile*secondsperHour, format: "%3.1f"))
							}
								.frame(width: mileSpeedWidth)
							
							//SplitsChartView(avgSpeed: eighthSplits[index].avgSpeed / metersperMile*secondsperHour, maxSpeed: maxSpeed)
							let barRatio = (mileSplits[index].avgSpeed / maxSpeed) * barWidth
							Rectangle()
								.fill(.white)
								.frame(width: barRatio)
							Rectangle()
								.fill(.clear)
								.frame(width: barWidth - barRatio)
							HStack  {
								Text(padStringWithFormat(value: mileSplits[index].gain * feetperMeter, format: "%6.1f"))
								Text(padStringWithFormat( value: mileSplits[index].grade*100, format: "%3.1f%%"))
							}.frame(width: gainGradeWidth)
							
						}
							
						
					}	//ForEach
				}
			
			
			
				
		} //VStack
	} // body
   		
}	//struct

struct SplitsView_Previews: PreviewProvider {
    static var previews: some View {
		let adventureIndex = 0
		if adventureData[adventureIndex].trackData.trkptsList.isEmpty {
				  adventureData[adventureIndex].trackData.trkptsList = sqlHikingData.sqlRetrieveTrkptlist(adventureData[adventureIndex].id)				//	retrieve the trackspoint list from the trackpointlist table in the database
			  }
		let adventureSplits = createSplits(trkptsList: adventureData[0].trackData.trkptsList)
		return SplitsView(eighthSplits: adventureSplits.eighthSplits, mileSplits: adventureSplits.mileSplits)
    }
}
