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
		let xaxisOffset : CGFloat = 40.0
			// pixels reserved for xaxis
		let keyLabelOffset : CGFloat = 30.0
		let gapWidth : CGFloat = 2.0
		let countOffset : CGFloat = 10.0		// offset to make count be at the inside top of the bars
		
		let topPadding : CGFloat = 20.0
		//let topReservedSpace = xaxisOffset + topPadding
			// pixels reserved for gap between chart and top of frame
		let yaxisOffset : CGFloat = 0.0
		let keyArray : Array<Double> = Array<Double>(histogramData.keys)
		let maxKey : CGFloat = histogramData.keys.max()!
			// maximum key (longest distance)
		let minKey : CGFloat = histogramData.keys.min()!
		let maxValue: CGFloat = CGFloat(histogramData.values.max()!)
			// maximum value in a single bin
		ZStack {
			DistributionHistogramChartView(histogramData: histogramData)
			BellCurveChartView(histogramData: histogramData)
		}
		
    }
}

struct DistributionChart_Previews: PreviewProvider {
    static var previews: some View {
		DistributionChart(histogramData:  [291.7924085343992: 0, 202.02165307623446: 0, 269.349719669858: 1, 336.67778626348155: 0, 179.57896421169326: 0, 157.13627534715206: 0, 89.80820875352852: 0, 44.92283102444615: 0, 246.90703080531682: 0, 134.6935864826109: 0, 224.46434194077563: 0, 67.36551988898734: 0, 314.23509739894035: 0, 22.0: 249, 360.0: 1, 112.2508976180697: 0])
    }
}
