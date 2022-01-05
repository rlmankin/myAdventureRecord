//
//  SliderView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 10/6/21.
//

import SwiftUI

struct SliderView : View {


	@Binding var filtervar : FilterRange
	var range : ClosedRange<Double>
	var label : String
	
	init(filtervar: Binding<FilterRange>,
		 range : ClosedRange<Double>,
		 label: String
		) {
		self._filtervar = filtervar
		self.range = range
		self.label = label
	}
	
	
    var body: some View {
		timeStampLog(message: "-> SliderView \(range), \(label)")
		return
			HStack (alignment: .center) {
				Text(label.padding(toLength: 20, withPad: " ", startingAt: 0))
					.font(.caption)
					.border(Color.orange)
					.padding(2.0)
				Spacer()
				RangeSlider(boundLowerValue: $filtervar.lower, boundUpperValue: $filtervar.upper, range: range, label: label, sliderFrameWidth: 450)
			}.frame(width: 500)
	}
}

struct SliderView_Previews: PreviewProvider {
    static var previews: some View {
		let filtervar = FilterVars()
		SliderView(filtervar: .constant(filtervar.searchLength), range: -100...100, label: "Test")
		
		
    }
}
