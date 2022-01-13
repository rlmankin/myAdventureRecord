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
		
		 
		var range : ClosedRange =  filtervars.searchLength.filterRange
		 
		timeStampLog(message: "-> filterSlider: range \(range)")
	return
		Group {
		 SliderView(filtervar: $filtervars.searchLength,
					range: filtervars.searchLength.baseRange,
					label: "Length (miles)")
		SliderView(filtervar: $filtervars.searchPace,
				   range: filtervars.searchPace.baseRange, label: "Pace (mph)")
		SliderView(filtervar: $filtervars.searchAscent,
				   range: filtervars.searchAscent.baseRange,
				   label: "Ascent (ft)")
		SliderView(filtervar: $filtervars.searchDescent,
				   range: filtervars.searchDescent.baseRange,
				   label: "Descent (ft)")
		SliderView(filtervar: $filtervars.searchMaxElevation,
				   range: filtervars.searchMaxElevation.baseRange,
				   label: "Elevation (ft)")
			
		}
	}
}
/*
struct FilterSlidersView_Previews: PreviewProvider {
    static var previews: some View {
        FilterSlidersView()
    }
}*/
