//
//  BellCurveChart.swift.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 11/12/21.
//

import SwiftUI
import SigmaSwiftStatistics

struct BellCurveChartView: View {
	var area : Double
	var mean : Double
	var sigma : Double
	var min : Double
	var max : Double
	
	
	
    var body: some View {
		let xaxisOffset : CGFloat = 40.0
			// pixels reserved for xaxis
		let yaxisOffset : CGFloat = 0.0
		
		let topPadding : CGFloat = 20.0
		
		let threeSigma : Double = 3 * sigma
		let xRange : Double = max - min
		let leftEdgeX : CGFloat = min
		let rightEdgeX : CGFloat = max
		
		GeometryReader { reader in
			let chartHeightInPixels : CGFloat = reader.size.height - xaxisOffset
				// chartheight in pixels
			let chartWidthinPixels : CGFloat  = reader.size.width - yaxisOffset
				// chartwidth in pixels
			//  Draw vertical lines for mean, -3sigma, and 3sigma
			// -3sigma
			Path { p in
				let xlocation = xlocationInPixels(x: leftEdgeX, chartWidthInPixels: chartWidthinPixels, xRange: xRange, min: min)
				p.move(to: CGPoint(x: xlocation, y: reader.size.height))
				p.addLine(to: CGPoint(x: xlocation, y: 0))
			}.stroke(.blue)
			Text(String(format: "%3.0f", leftEdgeX))
						  
			// mean
			Path { p in
				let xlocation = xlocationInPixels(x: mean, chartWidthInPixels: chartWidthinPixels, xRange: xRange, min: min)
					p.move(to: CGPoint(x: xlocation, y: reader.size.height))
					p.addLine(to: CGPoint(x: xlocation, y: 0))
			}.stroke(.blue)
			
			// +3sigma
			Path { p in
				let xlocation = xlocationInPixels(x: rightEdgeX, chartWidthInPixels: chartWidthinPixels, xRange: xRange, min: min)
					p.move(to: CGPoint(x: xlocation, y: reader.size.height))
					p.addLine(to: CGPoint(x: xlocation, y: 0))
			}.stroke(.yellow)
			Text(String(format: "%3.0f", rightEdgeX))
				.offset(x: xlocationInPixels(x: rightEdgeX, chartWidthInPixels: chartWidthinPixels, xRange: xRange, min: min) - 30)
			
			let strideStep : CGFloat = xRange / 50
			let xArray = Array(stride(from: leftEdgeX + strideStep, to: rightEdgeX, by: strideStep))
			let maxDensity = xArray.compactMap({Sigma.normalDensity(x: $0, μ: mean, σ: sigma)}).max()!
			ForEach (0 ..< xArray.endIndex, id: \.self) { index in
				let x = xArray[index]
				let xPrevInPixels = xlocationInPixels(x: x - strideStep, chartWidthInPixels: chartWidthinPixels, xRange: xRange, min: min)
				let xInPixels = xlocationInPixels(x: x, chartWidthInPixels: chartWidthinPixels, xRange: xRange, min: min)
				
				let densityPrev = CGFloat(Sigma.normalDensity(x: x - strideStep, μ: mean, σ: sigma)!)
				let density = CGFloat(Sigma.normalDensity(x: x, μ: mean, σ: sigma)!)
				
				let yPrevInPixels : CGFloat = ylocationInPixels(y: densityPrev, chartHeightinPixels: chartHeightInPixels, yRange: maxDensity)
				
				let yInPixels : CGFloat = ylocationInPixels(y: density, chartHeightinPixels: chartHeightInPixels, yRange: maxDensity)
				
				
				
				Path { p in
					p.move(to: CGPoint(x: xPrevInPixels, y: yPrevInPixels))
					p.addLine(to: CGPoint(x: xInPixels, y: yInPixels))
					//p.addRect(rect)
				}.stroke(.yellow)
				
				
			}
			
			
			
			
		}
		
        
    }
}

struct BellCurveChartView_Previews: PreviewProvider {
    static var previews: some View {
		let filteredAdventures =  adventureData.filter {$0.hikeCategory == .hike}
		let arry = filteredAdventures.compactMap({$0.distance / metersperMile})
		let histogramBins = populateHistorgramArray(arry: arry)
	
		let area = Double(histogramBins.data.keys.compactMap({histogramBins.data[$0]}).reduce(0,+))
		BellCurveChartView(	area: area,
						   	mean: Sigma.average(arry)!,
							sigma: Sigma.standardDeviationSample(arry)!,
							min : arry.min()!,
							max : arry.max()! )
    }
}
