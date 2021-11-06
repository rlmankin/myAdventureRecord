//
//  DistributionChart.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 11/2/21.
//

import SwiftUI

struct DistributionChart: View {
	var histogramData : [Double: Int]
	
    var body: some View {
		let xaxisOffset = 40.0										// pixels reserved for xaxis
		let topReservedSpace = 20.0									// pixels reserved for gap between chart and top of frame
		let yaxisOffset = 0.0
		let gapWidth = 2.0
		var countOffset : CGFloat = 15.0		// offset to make count be at the inside top of the bars
		let keyArray = Array<Double>(histogramData.keys)
		let maxKey = histogramData.keys.max()!
			// maximum key (longest distance)
		let minKey = histogramData.keys.min()!
		let maxValue = histogramData.values.max()!
			// maximum value in a single bin
		
		
		GeometryReader { reader in
			let chartHeight = CGFloat(reader.size.height - xaxisOffset)
				// chartheight in pixels
			let chartWidth = CGFloat(reader.size.width - yaxisOffset)
			
			let binWidth = CGFloat((1.0*reader.size.width)/CGFloat(histogramData.count))
				// binWidth in pixels
			
			let singleWidth = chartWidth/CGFloat(maxKey)
				// width of a single pxiel (in miles)
			let singleHeight = chartHeight/CGFloat(maxValue)
				// height of a value of 1
			ForEach (keyArray, id: \.self) { key in
				let valueHeight = CGFloat(histogramData[key]!) * singleHeight
				let keyXOffset = (key * singleWidth) - minKey
				Path { p in
					//p.move(to: CGPoint(x: key*binWidth, y:0))
					p.move(to: CGPoint(x: keyXOffset, y:0))
					let rect = CGRect(x: keyXOffset, y: chartHeight-valueHeight, width:binWidth - gapWidth,height: valueHeight)
					p.addRoundedRect(in: rect, cornerSize: CGSize(width: binWidth/10, height: binWidth/10))
				}
				VStack {
					let x = String(format:"%3.0f", key)
					Text("\(x)")
						.foregroundColor(.white)
						.rotationEffect(.degrees(-90))
						.offset(x:keyXOffset, y: reader.size.height - 30)
					
					
					
					Text("\(histogramData[key]!)")
						//.foregroundColor(monthHeight < 40 ? .gray : .white)
						.offset(x:keyXOffset,
					 			y: chartHeight - valueHeight - 45)
								//y: chartHeight-valueHeight - (valueHeight < 40 ? 45 : 10))
						.foregroundColor(.gray)
						/*.offset(x: index*binWidth,
								y: chartHeight - monthHeight - 45)*/
					
				}
				.frame(width: binWidth)
				//Text("\(key), \(valueHeight)").offset(y:10*key)
				
			}
		}.padding(top: 20)
    }
}

struct DistributionChart_Previews: PreviewProvider {
    static var previews: some View {
		DistributionChart(histogramData: [291.7924085343992: 0, 202.02165307623446: 0, 269.349719669858: 1, 336.67778626348155: 0, 179.57896421169326: 0, 157.13627534715206: 0, 89.80820875352852: 0, 44.92283102444615: 0, 246.90703080531682: 0, 134.6935864826109: 0, 224.46434194077563: 0, 67.36551988898734: 0, 314.23509739894035: 0, 22.0: 249, 360.0: 1, 112.2508976180697: 0])
    }
}
