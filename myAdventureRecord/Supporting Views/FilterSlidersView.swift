//
//  FilterSlidersView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 12/29/21.
//

import SwiftUI

struct FilterSlidersView: View {
	@Binding var filtervars: FilterVars
	
	
    var body: some View {
		
		 
		var range : ClosedRange =  filtervars.searchLength.lower ... filtervars.searchLength.upper
		 
		timeStampLog(message: "-> filterSlider: range \(range)")
	return
		Group {
		 SliderView(filtervar: $filtervars.searchLength,
					range: range,
					label: "Length (miles)")
		// SliderView(filtervar: $filtervars.searchPace, range: 0.0 ... 75.0, label: "Pace (mph)")
		// SliderView(filtervar: $filtervars.searchAscent, range: 0.0 ... 30000.0, label: "Ascent (ft)")
		// SliderView(filtervar: $filtervars.searchDescent, range: -20000.0 ... 0, label: "Descent (ft)")
		// SliderView(filtervar: $filtervars.searchMaxElevation, range: 0 ... 15000, label: "Elevation (ft)")
			
		}
	}
}
/*
struct FilterSlidersView_Previews: PreviewProvider {
    static var previews: some View {
        FilterSlidersView()
    }
}*/
