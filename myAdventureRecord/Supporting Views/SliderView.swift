//
//  SliderView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 10/6/21.
//

import SwiftUI

struct SliderView : View {


	@Binding var filtervar : FilterRange
	var valueRange : ClosedRange<Double>
	var valueString : String
	var baseMinValue : Double
	var baseMaxValue : Double
	
	init(filtervar: Binding<FilterRange>,
		 valueRange : ClosedRange<Double>,
		 valueString: String,
		 baseMinValue: Double,
		 baseMaxValue: Double
		) {
		self._filtervar = filtervar
		self.valueRange = valueRange
		self.valueString = valueString
		self.baseMinValue = baseMinValue
		self.baseMaxValue = baseMaxValue
	}
	
	
    var body: some View {
		timeStampLog(message: "SliderView")
		return
			HStack (alignment: .center) {
				Text(valueString.padding(toLength: 20, withPad: " ", startingAt: 0))
					.font(.caption)
					.border(Color.orange)
					.padding(2.0)
				Spacer()
				RangeSlider(boundLowerValue: $filtervar.lower, boundUpperValue: $filtervar.upper, range: baseMinValue ... baseMaxValue, label: "Length", sliderFrameWidth: 450)
			}.frame(width: 500)
	}
}

struct SliderView_Previews: PreviewProvider {
    static var previews: some View {
		let filtervar = FilterVars()
		SliderView(filtervar: .constant(filtervar.searchLength), valueRange: -100...100, valueString: "Test", baseMinValue: -100, baseMaxValue: 100)
		
		
    }
}
