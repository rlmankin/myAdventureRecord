//
//  MonthHistogramView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 10/31/21.
//

import SwiftUI

struct MonthHistogramView: View {
	let monthArray : [String] =  ["Jan", "Feb", "Mar","Apr", "May", "Jun",
								  "Jul", "Aug", "Sep","Oct", "Nov", "Dec"]
	var monthDict : [String: Int]
	
    var body: some View {
		let xaxisOffset : CGFloat = 40.0
		let gapWidth : CGFloat = 2.0
		var countOffset : CGFloat = 25		// offset to make count be at the inside top of the bars
		GeometryReader { reader in
			let chartHeight = CGFloat(reader.size.height - xaxisOffset)
			
			let binWidth = CGFloat((1.0*reader.size.width)/12)
			let maxCount = CGFloat(monthDict.values.max()!)				// maximum count in a month
			let singleHeight = chartHeight/maxCount		// height of a count of one
			
			ForEach (monthArray, id:\.self) {month in
				// putting all calculations in individual variables to 1) improve type-checking,
				//		2) improve performace (slightly), 3) reduce memory pressure (maybe)
				let index = CGFloat(monthArray.firstIndex(where: {$0 == month})!)
				let monthHeight  = CGFloat(monthDict[month]!) * singleHeight
				let rectx = index * binWidth
				let recty = chartHeight - monthHeight
				let rectw = binWidth - gapWidth
				let rect = CGRect(x: rectx, y: recty, width:rectw, height: monthHeight)
				let cornerSize = CGSize(width: binWidth/10, height: binWidth/10)
				let valueOffset = recty - (monthHeight < xaxisOffset ? xaxisOffset : xaxisOffset - countOffset)
				Path { p in
					p.addRoundedRect(in: rect, cornerSize: cornerSize)
				}
				
				VStack {
					Text("\(month)")
						.foregroundColor(.white)
						.rotationEffect(.degrees(-90))
						.offset(x:rectx, y: reader.size.height - xaxisOffset + 10)
							// 10 point from bottom of bars
					Text("\(monthDict[month]!)")
						//.foregroundColor(monthHeight < 40 ? .gray : .white)
						.offset(x:rectx,
								y: valueOffset)
						.foregroundColor(.gray)
					
				}
				.frame(width: binWidth)
			}
			
		
		}
  
	}
}

struct MonthHistogramView_Previews: PreviewProvider {
    static var previews: some View {
        MonthHistogramView(monthDict: ["Jan" : 6, "Feb":8, "Mar":4,
									   "Apr" : 10, "May":20, "Jun":30,
									   "Jul" : 35, "Aug":30, "Sep":20,
									   "Oct" : 50, "Nov":1, "Dec":8])
    }
}
