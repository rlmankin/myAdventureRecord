//
//  FilterView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 9/28/21.
//

import SwiftUI


struct FilterView: View {
	//@EnvironmentObject var userData: UserData
	@Binding var filtervars: FilterVars
	/*
	@Binding  var filterBy :  Adventure.HikeCategory
	@Binding  var searchArea : String
	@Binding  var searchTitle : String
	@Binding  var searchLength : Double
	 */
	@Binding  var stateFlag : FlagStates?
	
	
	func setStateToDefault() {
		filtervars.setVarsToDefault()
		stateFlag = FlagStates.empty
		
	}
	
    var body: some View {
		VStack(alignment: .leading) {
			
			HStack {
				Spacer()
				Text("Type")
					.font(.headline)
				Spacer()
			}
			HStack {
				ForEach ( Adventure.HikeCategory.allCases, id: \.self) { category in
					Button(category.description, action: {filtervars.filterBy = category})
				}
			}
			HStack {
				Text("Area")
				TextField(filtervars.searchArea, text: $filtervars.searchArea)
			}
			HStack {
				Text("Name")
				TextField(filtervars.searchTitle, text: $filtervars.searchTitle)
			}
			
			SliderView(filtervar: $filtervars.searchDescent, valueString: "Length (miles)", minValue: 0.0, maxValue: 300.0)
			SliderView(filtervar: $filtervars.searchPace, valueString: "Pace (mph)", minValue: 0.0, maxValue: 4.0)
			SliderView(filtervar: $filtervars.searchAscent, valueString: "Ascent (ft)", minValue: 0.0, maxValue: 6000.0)
			SliderView(filtervar: $filtervars.searchDescent, valueString: "Descent (ft)", minValue: 0.0, maxValue: 6000.0)
			SliderView(filtervar: $filtervars.searchMaxElevation, valueString: "Elevation (ft)", minValue: 0.0, maxValue: 15000.0)
			
			Button("Cancel", action: {self.setStateToDefault()})
			
		}
	}
}


struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
		let filtervars = FilterVars()
		Group {
			FilterView(filtervars: .constant(filtervars), stateFlag: .constant(FlagStates.showFilterView))
				.padding()
		}
			
    }
}

