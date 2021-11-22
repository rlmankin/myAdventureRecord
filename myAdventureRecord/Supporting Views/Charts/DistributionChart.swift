//
//  DistributionChart.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 11/2/21.
//

import SwiftUI
import SigmaSwiftStatistics

func populateHistorgramArray(arry: [Double]) -> (data: [Double: Int], mean: Double, sigma: Double, min: Double, max: Double) {
	guard let mean = Sigma.average(arry),
		  let sigma = Sigma.standardDeviationSample(arry)
	else {
		timeStampLog(message: "arry has no min and/or max")
		return ([0.0:0], 0, 0, 0, 0)
	}
	var binKeys : [Double] = []
	var binValues : [Int] = []
	let max = /*ceil*/(max( mean + (3*sigma), arry.max()!))
	let min = /*floor*/(min( mean - (3*sigma), arry.min()!))
	let range = max - min
	let count = arry.count
	let numBins = Swift.max(/*ceil*/(sqrt(Double(range)))	, /*ceil*/(sqrt(Double(count))))// round up the sqrt
	//  alternate : numBins = ceil(sqrt(Double(range)
	//  alternate : numBins = ceil(sqrt(Double(count)
	let binWidth = range/numBins
	// populate binValues
	
	for bin in 0 ..<  Int(ceil(numBins)) {
		binKeys.append(min + Double(bin) * binWidth)
	}
	binKeys[0] = /*floor*/(binKeys[0])
	binKeys[binKeys.endIndex-1] = /*ceil*/(binKeys[binKeys.endIndex-1])
	//binValues.append(arry.filter {$0 <= binKeys[0]}.count)
	for bin in (0 ..< binKeys.endIndex) {
		if bin == 0 {
			binValues.append( arry.filter({$0 < binKeys[bin]}).count)
		} else if bin == binKeys.endIndex - 1 {
			binValues.append(arry.filter({$0 > binKeys[bin]}).count)
		} else {
			binValues.append(arry.filter({$0 >= binKeys[bin] && $0 < binKeys[bin + 1]}).count)		//count   binKey[bin] <= values < binKey[bin + 1]
		}
		
			
		}
	
	
	let binDict = Dictionary(uniqueKeysWithValues: zip(binKeys, binValues))
	let sortedbinDict = binDict.sorted(by: {$0.0 < $1.0})
	//print("\(binDict)\n mean: \(mean),\t sigma: \(sigma)")
	return (binDict, mean, sigma, min, max)
}

struct DistributionChart: View {
	var filteredAdventures : [Double] = []
	
	
	
    var body: some View {
		
		let histogramBins = populateHistorgramArray(arry: filteredAdventures)
		let mean = histogramBins.mean
		let sigma = histogramBins.sigma
		let min = histogramBins.min
		let max = histogramBins.max
		let area = Double(histogramBins.data.keys.compactMap({histogramBins.data[$0]}).reduce(0,+))
		
		
		
			// maximum value in a single bin
		ZStack {
			
			BellCurveChartView(area: area , mean: mean, sigma: sigma, min: min, max: max)
			DistributionHistogramChartView(histogramBins: histogramBins.data)
		}
		
    }
}

struct DistributionChart_Previews: PreviewProvider {
    static var previews: some View {
		let filteredAdventures =  adventureData.filter {$0.hikeCategory == .hike}
		let arry = filteredAdventures.compactMap({$0.distance / metersperMile})
		
		DistributionChart(filteredAdventures: arry)
    }
}
