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
	
	func padNumberWithFormat (value : Double, format: String) -> String {
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
			
			SplitHeaderView(header: "Mile Splits", value: ["#","mph","feet","grade"], format: [10,10,10,10], width: [mileSpeedWidth, barWidth, gainGradeWidth], fixedLength: fixedLength)
				.border(.green)
			
			List {
				ForEach (0 ..< mileSplits.endIndex, id: \.self) {index in
					HStack {
						HStack {
							Text(padNumberWithFormat(value: Double(index), format: "%3.0f"))
							Text( padNumberWithFormat( value: mileSplits[index].avgSpeed / metersperMile*secondsperHour, format: "%3.1f"))
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
							Text(padNumberWithFormat(value: mileSplits[index].gain * feetperMeter, format: "%6.1f"))
							Text(padNumberWithFormat( value: mileSplits[index].grade*100, format: "%3.1f%%"))
						}.frame(width: gainGradeWidth)
						
					}.frame(height: 15)
				}
			}.border(.yellow)
			SplitHeaderView(header: "1/8 mile Splits", value: ["#","mph","feet","grade"], format: [3,3,6,3], width: [mileSpeedWidth, barWidth, gainGradeWidth], fixedLength: fixedLength)
			
			List {
				
				ForEach (0 ..< eighthSplits.endIndex, id: \.self) {index in
					HStack {
						HStack {
							Text(padNumberWithFormat(value: Double(index), format: "%3.0f"))
							Text( padNumberWithFormat( value: eighthSplits[index].avgSpeed / metersperMile*secondsperHour, format: "%3.1f"))
						}
							.frame(width: mileSpeedWidth)
						
						let barRatio = (eighthSplits[index].avgSpeed / maxSpeed) * barWidth
						Rectangle()
							.fill(.white)
							.frame(width: barRatio)
						Rectangle()
							.fill(.clear)
							.frame(width: barWidth - barRatio)
						HStack  {
							Text(padNumberWithFormat(value: eighthSplits[index].gain * feetperMeter, format: "%5.1f"))
							Text(padNumberWithFormat( value: eighthSplits[index].grade*100, format: "%3.1f%%"))
						}.frame(width: gainGradeWidth)
						
					}
						
						
				} // ForEach
			}	//List
		
			
			
			
				
		}//.fixedSize(horizontal: true, vertical: false) //VStack
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
