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
		let sliderWidth = Float(450.0)
		return
		HStack (alignment: .bottom) {
			Text(valueString)
			RangeSlider(boundLowerValue: $filtervar.lower, boundUpperValue: $filtervar.upper, range: baseMinValue ... baseMaxValue, label: "Length", sliderFrameWidth: 500)
			/*
			RangeSlider(
				minValue: self.$filtervar.lower, // mimimum value
				maxValue: self.$filtervar.upper, // maximum value
				valueSpan: self.valueSpan,
				minLabel: String(originalMinValue), // mimimum Label text
				maxLabel: String(maxValue), // maximum Label text
				sliderWidth: sliderWidth, // set slider width
				backgroundTrackColor: Color(.systemTeal).opacity(0.5), // track color
				selectedTrackColor: Color.blue.opacity(25), // track color
				globeColor: Color.orange, // globe background color
				globeBackgroundColor: Color.black, // globe rounded border color
				sliderMinMaxValuesColor: Color.white // all text label color
			)
			 */
		}.frame(width: 500)
		
		
			
		
		
			
		
			/*ZStack {
				let valueRange = minValue ... maxValue
				
				Slider (value: $filtervar.lower,
						in: -maxValue ... -minValue,
						minimumValueLabel: Text(String(format: "%5.0f", minValue)),
						maximumValueLabel: Text(String(format: "%5.0f", maxValue)),
						label: {Text(valueString.padding(toLength: 15, withPad: " ", startingAt: 0)).frame(width: 90, alignment: .leading)})
					.controlSize(.small)
				Slider (value: $filtervar.upper,
						in: minValue ... maxValue,
						minimumValueLabel: Text(String(format: "%5.0f", minValue)),
						maximumValueLabel: Text(String(format: "%5.0f", maxValue)),
						label: {Text(valueString.padding(toLength: 15, withPad: " ", startingAt: 0)).frame(width: 90, alignment: .leading)})
					.controlSize(.small)
		
				Text(String(format: "%5.0f, %5.0f || %5.0f, %5.0f", minValue, maxValue, maxValue+filtervar.lower, filtervar.upper))
					.offset(x: 45, y:10)
			}
			 */
	}
}

struct SliderView_Previews: PreviewProvider {
    static var previews: some View {
		let filtervar = FilterVars()
		//SliderView(filtervar: .constant(filtervar.searchLength), valueString: "test", minValue: -300.0, maxValue: 50.0)
		//	.padding(4.0)
    }
}
