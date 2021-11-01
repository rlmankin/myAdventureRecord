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
		let xaxisOffset = 40.0
		let gapWidth = 2.0
		GeometryReader { reader in
			let chartHeight = CGFloat(reader.size.height - xaxisOffset)
			
			let binWidth = CGFloat((1.0*reader.size.width)/12)
			let maxCount = monthDict.values.max()!					// maximum count in a month
			let singleHeight = chartHeight/CGFloat(maxCount)		// height of a count of one
			
			ForEach (monthArray, id:\.self) {month in
				let index = CGFloat(monthArray.firstIndex(where: {$0 == month})!)
				let monthHeight  = CGFloat(monthDict[month]!) * singleHeight
				
				Path { p in
					p.move(to:CGPoint(x:index*binWidth, y: 0))
					let rect = CGRect(x: index*binWidth, y: chartHeight-monthHeight, width:binWidth - gapWidth,height: monthHeight
					)
					p.addRoundedRect(in: rect, cornerSize: CGSize(width: binWidth/10, height: binWidth/10))
					
				}
				
				VStack {
					Text("\(month)")
						.foregroundColor(.white)
						.rotationEffect(.degrees(-90))
						.offset(x:index*binWidth, y: reader.size.height - 30)
					Text("\(monthDict[month]!)")
						.foregroundColor(.black)
						.offset(x:index*binWidth, y: chartHeight-monthHeight)
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
