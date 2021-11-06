//
//  SplashTabView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 10/27/21.
//

import SwiftUI
import SigmaSwiftStatistics

struct SplashTabView: View {
	var filteredAdventures : [Double] = []
	var filteredAdventuresName : [String] = []
	
	func populateHistorgramArray(arry: [Double]) -> ([Double: Int]) {
		guard let min = arry.min(), let max = arry.max() else {
			timeStampLog(message: "arry has no min and/or max")
			return [0.0:0]
		}
		var binKeys : [Double] = []
		var binValues : [Int] = []
		let range = max - min
		let count = arry.count
		let numBins = ceil(sqrt(Double(count)))	// round up the sqrt
		let binWidth = range/numBins
		// populate binValues
		
		for bin in 0 ..<  Int(ceil(numBins)) {
			binKeys.append(min + Double(bin+1) * binWidth)
		}
		binKeys[0] = floor(binKeys[0])
		binKeys[binKeys.endIndex-1] = ceil(binKeys[binKeys.endIndex-1])
		binValues.append(arry.filter {$0 <= binKeys[0]}.count)
		for bin in (1 ..< binKeys.endIndex) {
			binValues.append(arry.filter({$0 <= binKeys[bin] && $0 > binKeys[bin - 1]}).count)
		}
		
		let binDict = Dictionary(uniqueKeysWithValues: zip(binKeys, binValues))
		print(binDict)
		return binDict
	}
	
    var body: some View {
		VStack {
			GeometryReader { proxy in
				HStack {
					DescriptiveStatsView(filteredAdventures: filteredAdventures,
										 filteredAdventuresName: filteredAdventuresName)
						.frame(width: proxy.size.width/2)
					
						let histogramBins = populateHistorgramArray(arry: filteredAdventures)
						DistributionChart(histogramData: histogramBins)
							.frame(width: proxy.size.width/2)
				}
			}
		}
    }
}

struct SplashTabView_Previews: PreviewProvider {
    static var previews: some View {
		let arry = adventureData.compactMap({$0.distance / metersperMile})
		let arryName = adventureData.compactMap({$0.name})
        SplashTabView(filteredAdventures: arry,
						filteredAdventuresName: arryName)
    }
}
