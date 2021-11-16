//
//  DescriptiveStatsView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 11/2/21.
//

import SwiftUI
import SigmaSwiftStatistics

struct DescriptiveStatsView: View {
	var filteredAdventures : [Double] = [0]
	var filteredAdventuresName : [String] = ["empty"]
	
    var body: some View {
		
		VStack (alignment: .leading) {
			let arry = filteredAdventures  //[82.0, 93.0, 91.0, 69.0, 61.0,88.0, 58.0, 59.0, 100.0, 93.0, 71.0, 78.0, 98.0]	//
			Text(String( format: "Descriptive Statistics (%4d datapoints)", arry.count))
				.font(.headline).bold().italic()
				.padding(.bottom, 6)
			
			
			
			//kurtosis & skewness
			if let stat = Sigma.kurtosisA(arry) {
				if let stat1 = Sigma.skewnessA(arry) {
					HStack {
						Text(String( format: "Skewness: %5.3f", stat1))
							.padding(.trailing)
						Text(String( format: "Kurtosis: %5.3f", stat))
						
					}
					.font(.subheadline)
					.alignmentGuide(.leading, computeValue: {_ in -10})
				}
			}
			
			let min = arry.min() ?? 0
			let max = arry.max() ?? 0
			let indexMin = arry.firstIndex(where: {$0 == min})!
			let indexMax = arry.firstIndex(where: {$0 == max})!
			let stdDeviation = Sigma.standardDeviationSample(arry)!
			let mean = Sigma.average(arry)!
			HStack {
				
				if let stat = Sigma.average(arry) {
					Text(String(format: "Mean:  %5.3f" , stat))
						.padding(.trailing)
				}
					//median
				if let stat = Sigma.median(arry) {
					Text(String(format:"Median: %5.3f", stat))
						.padding(.trailing)
				}
					//standard devisation
				if let stat = stdDeviation {
					Text(String(format: "Std Deviation: %5.3f", stat))
				}
			}
			.font(.subheadline)
			.alignmentGuide(.leading, computeValue: {_ in -10})
			VStack (alignment: .leading) {
				
				
				Text(String(format: "Min:  %5.3f\t -%1.2f sigma" , min, (mean-min) / stdDeviation))
					.padding(.trailing)
				Text("\t\(filteredAdventuresName[indexMin])")
				Text(String(format:"Max: %5.3f\t %1.2f sigma", max, (max-mean) / stdDeviation))
					.padding(.trailing)
				Text("\t\(filteredAdventuresName[indexMax])")
				Text(String(format: "Range: %5.3f", max-min))
			}
			.font(.subheadline)
			.alignmentGuide(.leading, computeValue: {_ in -10})
			
			
			
			
		}
    }
}

struct DescriptiveStatsView_Previews: PreviewProvider {
    static var previews: some View {
		let arry = adventureData.compactMap({$0.distance / metersperMile})
		let arryName = adventureData.compactMap({$0.name})
        DescriptiveStatsView(filteredAdventures: arry, filteredAdventuresName: arryName)
		/*
		let arry1 = adventureData.compactMap({$0.trackData.trackSummary.totalAscent / feetperMeter})
		let arry1Name = adventureData.compactMap({$0.name})
		DescriptiveStatsView(filteredAdventures: arry1, filteredAdventuresName: arry1Name)
		
		let arry2 = adventureData.compactMap({$0.trackData.trackSummary.duration / secondsperHour})
		let arry2Name = adventureData.compactMap({$0.name})
		DescriptiveStatsView(filteredAdventures: arry2, filteredAdventuresName: arry2Name)*/
    }
}
