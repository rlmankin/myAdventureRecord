//
//  SliderView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 10/6/21.
//

import SwiftUI

struct SliderView : View {


	@Binding var filtervar : Double
	var valueString : String
	var minValue : Double
	var maxValue : Double
	
	
    var body: some View {
		VStack {
			HStack {
				let valueRange = minValue ... maxValue
				Slider (value: $filtervar,
						in: valueRange,
						minimumValueLabel: Text(String(format: "%5.0f", minValue)),
						maximumValueLabel: Text(String(format: "%5.0f", maxValue)),
						label: {Text(valueString)})
				Spacer()
			}
			Text(String(format: "%5.0f", filtervar))
		}
	}
}

struct SliderView_Previews: PreviewProvider {
    static var previews: some View {
		let filtervar = FilterVars()
		SliderView(filtervar: .constant(filtervar.searchDescent), valueString: "test", minValue: 5.0, maxValue: 20.0)
    }
}
