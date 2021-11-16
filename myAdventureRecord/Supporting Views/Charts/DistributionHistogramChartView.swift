//
//  DistributionHistogramChartView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 11/12/21.
//

import SwiftUI

struct DistributionHistogramChartView: View {
	var histogramBins : [Double: Int]
	
	
	
	var body: some View {
		let xaxisOffset : CGFloat = 40.0
			// pixels reserved for xaxis
		let yaxisOffset : CGFloat = 0.0
		let keyLabelOffset : CGFloat = 35.0
		let gapWidth : CGFloat = 2.0
		let countOffset : CGFloat = 20.0		// offset to make count be at the inside top of the bars
		
		let topPadding : CGFloat = 20.0
		//let topReservedSpace = xaxisOffset + topPadding
			// pixels reserved for gap between chart and top of frame
		
		let keyArray : Array<Double> = Array<Double>(histogramBins.keys).sorted(by: { $0 < $1 })
		let maxKey : CGFloat = histogramBins.keys.max()!
			// maximum key (longest distance)
		let minKey : CGFloat = histogramBins.keys.min()!
		let xRange : Double = Double(maxKey - minKey)
		let maxValue: CGFloat = CGFloat(histogramBins.values.max()!)
			// maximum value in a single bin

		VStack {
			GeometryReader { reader in
				let chartHeight : CGFloat = reader.size.height - xaxisOffset
					// chartheight in pixels
				let chartWidth : CGFloat  = reader.size.width - yaxisOffset
					// chartheight in pixels
				let binWidth : CGFloat = chartWidth/CGFloat(histogramBins.count)
					// binWidth in pixels
				let rectw : CGFloat = binWidth - gapWidth
				let singleWidth : CGFloat = chartWidth/(maxKey - minKey)
					// width of a single pxiel (in miles)
				let singleHeight : CGFloat = chartHeight/maxValue
					// height of a value of 1
				
				ForEach (keyArray, id: \.self) { key in
					let valueHeight : CGFloat = CGFloat(histogramBins[key]!) * singleHeight
					//let rectx : CGFloat = ((CGFloat(key) * singleWidth) - minKey < 0 ? 0 : (CGFloat(key) * singleWidth) - minKey)
					//let rectx : CGFloat = (CGFloat(key) - minKey ) * singleWidth
					let rectx : CGFloat = xlocationInPixels(x: key, chartWidthInPixels: chartWidth, xRange: xRange, min: minKey)
					//let recty : CGFloat = chartHeight - valueHeight
					let recty : CGFloat = ylocationInPixels(y: Double(histogramBins[key]!), chartHeightinPixels: chartHeight, yRange: maxValue)
					let rect : CGRect = CGRect(x: rectx, y: recty, width:rectw, height: valueHeight)
					let cornerSize : CGSize = CGSize(width: binWidth/10, height: binWidth/10)
					let valueOffset : CGFloat = recty - xaxisOffset - (valueHeight < xaxisOffset ? valueHeight + countOffset : 0)
					
					Path { p in
						p.addRoundedRect(in: rect, cornerSize: cornerSize)
					}
					Path {p in
						p.move(to: CGPoint(x: rectx, y: reader.size.height))
						p.addLine(to: CGPoint(x: rectx, y: 0))
					
					}.stroke(.yellow)
		
					VStack  {
						let keyString : String = String(format:"%3.2f", key)
						Text("\(keyString)")		// xaxis labels
							.alignmentGuide(.trailing, computeValue: { _ in 0 })
							.font(.subheadline)
							.foregroundColor(.white)
							.rotationEffect(.degrees(-90))
							.offset(x:rectx, y: reader.size.height - xaxisOffset - 0)
							.frame(width: binWidth, height: xaxisOffset, alignment: .trailing)
						
						Text("\(rectx)")		// xaxis labels
							.alignmentGuide(.trailing, computeValue: { _ in 0 })
							.font(.subheadline)
							.foregroundColor(.yellow)
							.rotationEffect(.degrees(-90))
							.offset(x:rectx, y: reader.size.height/2)
							.border(.green, width: 2)
							.frame(width: binWidth, height: xaxisOffset, alignment: .trailing)
						
							// This section is written this way, versus something more elegant, to
							//	assist the Swift compile to type check complex statements.  This is
							//	to (hopefully) reduce the instances of runaway SourceKitService and
							//	swift - frontend memory pressure
						let valueString : String = histogramBins[key]! == 0 ? nullString :
								String(format: "%3d", histogramBins[key]!)
						Text(valueString)
							.font(.subheadline)
							.foregroundColor(valueHeight < 40 ? .yellow : .green)
							.offset(x: rectx,
									y: valueOffset)
					}
					.frame(width: binWidth)
				}
			}.padding(.top, topPadding)
			//Text("Distribution")
			}
		}
}

struct DistributionHistogramChartView_Previews: PreviewProvider {
    static var previews: some View {
		let filteredAdventures =  adventureData.filter {$0.hikeCategory == .hike}
		
		let arry = filteredAdventures.compactMap({$0.distance / metersperMile})
		let arryBins = populateHistorgramArray(arry : arry)
		DistributionHistogramChartView(histogramBins:  arryBins.data)
    }
}
