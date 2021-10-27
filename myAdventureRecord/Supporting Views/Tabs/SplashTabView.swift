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
	
    var body: some View {
		VStack {
			let arry = filteredAdventures  //[82.0, 93.0, 91.0, 69.0, 61.0,88.0, 58.0, 59.0, 100.0, 93.0, 71.0, 78.0, 98.0]	//
			Text(String( format: "Descriptive Statistics (%4d)", arry.count))
			HStack {
				Spacer()
				if let stat = Sigma.average(arry) {
					Text(String(format: "Mean:  %5.3f" , stat))
				}
				Spacer()
					//median
				if let stat = Sigma.median(arry) {
					Text(String(format:"Median: %5.3f", stat))
				}
				Spacer()
					//standard devisation
				if let stat = Sigma.standardDeviationSample(arry) {
					Text(String(format: "Std Deviation: %5.3f", stat))
				}
				Spacer()
			}
			
			
			//kurtosis & skewness
			if let stat = Sigma.kurtosisA(arry) {
				if let stat1 = Sigma.skewnessA(arry) {
					Text(String( format: "Skewness: %5.3f\t\t\t Kurtosis: %5.3f", stat1, stat))
				}
			}
			
			let min = arry.min()!
			let max = arry.max()!
			let indexMin = arry.firstIndex(where: {$0 == min})!
			let indexMax = arry.firstIndex(where: {$0 == max})!
			Text(String(format: "Min: %5.3f\t Max: %5.3f\t Range:  %5.3f", min, max, max - min))
			Text("Min: \(filteredAdventuresName[indexMin])")
			Text("Max: \(filteredAdventuresName[indexMax])")
			
			
			
			
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
