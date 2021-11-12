//
//  BellCurveChart.swift.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 11/12/21.
//

import SwiftUI
import SigmaSwiftStatistics

struct BellCurveChartView: View {
var histogramData : [Double : Int]
	
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
		let keyRange : CGFloat = maxKey - minKey
		let maxValue: CGFloat = CGFloat(histogramData.values.max()!)
		
		let histogramDataSigma : Double = Sigma.standardDeviationSample((keyArray))!
		let histogramDataMean : Double = Sigma.average(keyArray)!
		let sixSigma : Double = 6 * histogramDataSigma
		let xaxisValues : [Double] = Array(stride(from: minKey, through: maxKey, by: 5) )
		let area = histogramData.values.compactMap({$0}).reduce(0,+)
		
		var xaxisValueProbability : [Double] = []
		/*
		 ForEach (xaxisValues, id: \.self) { xaxisValue in
			 xaxisValueProbability.append(Sigma.normalDistribution(x: xaxisValue, μ: histogramDataMean, σ: histogramDataSigma)!)
		}
		 */
		GeometryReader { reader in
			let chartHeight : CGFloat = reader.size.height - xaxisOffset
				// chartheight in pixels
			let chartWidth : CGFloat  = reader.size.width - yaxisOffset
			let singleWidth : CGFloat = chartWidth/keyRange
				// chartheight in pixels
			ForEach (1 ..< xaxisValues.endIndex, id: \.self) { item in
				let previousXAxisValue: CGFloat = xaxisValues[item - 1]
				let xaxisValue : CGFloat = xaxisValues[item]
				let previousValueHeight : CGFloat = reader.size.height -  CGFloat(Sigma.normalDensity(x: previousXAxisValue, μ: histogramDataMean, σ: histogramDataSigma)!) * CGFloat(area) * chartHeight
				let valueHeight : CGFloat = reader.size.height - CGFloat(Sigma.normalDensity(x: xaxisValue, μ: histogramDataMean, σ: histogramDataSigma)!) * CGFloat(area) * chartHeight
				//let rectx : CGFloat = ((CGFloat(xaxisValue)-minKey) * singleWidth)
				//let recty : CGFloat = chartHeight - valueHeight
				//let rect : CGRect = CGRect(x: rectx, y: recty, width: singleWidth, height: //valueHeight)
				//let previousP : CGFloat = 0
				Path { p in
					p.move(to: CGPoint(x:previousXAxisValue, y: previousValueHeight))
					p.addLine(to: CGPoint(x: xaxisValue, y: valueHeight))
					//p.addRect(rect)
				}.stroke(.yellow)
				Text(String(format:"%3d", Int(xaxisValue)))
					.font(.subheadline)
					.rotationEffect(.degrees(90))
					.offset(x:xaxisValue, y: reader.size.height - keyLabelOffset)
				 
				
			}
			
		}
		
        Text("Hello, World! \(histogramDataSigma), \(sixSigma)")
    }
}

struct BellCurveChartView_Previews: PreviewProvider {
    static var previews: some View {
		BellCurveChartView(histogramData: [291.7924085343992: 0, 202.02165307623446: 0, 269.349719669858: 1, 336.67778626348155: 0, 179.57896421169326: 0, 157.13627534715206: 0, 89.80820875352852: 0, 44.92283102444615: 0, 246.90703080531682: 0, 134.6935864826109: 0, 224.46434194077563: 0, 67.36551988898734: 0, 314.23509739894035: 0, 22.0: 249, 360.0: 1, 112.2508976180697: 0])
    }
}
