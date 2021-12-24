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
	@Binding  var stateFlag : FlagStates?
	// populate the button category array
	@State private var categoryButtonOpacity : [Adventure.HikeCategory: Double] = {
		var tempDict : [Adventure.HikeCategory: Double] = [:]
		for key in Adventure.HikeCategory.allCases {
			tempDict[key] = 0.5
		}
		return tempDict
	}()
	
	
	func setStateToDefault() {
		filtervars.setVarsToDefault()
		stateFlag = FlagStates.empty
		
	}
	
	
	
    var body: some View {
		
		
		
		timeStampLog(message: "-> FilterView")
		
		return
			VStack(alignment: .leading) {
				Group {		// required to overcome 10 view limit
					
					FilterButtonsView(filtervars: $filtervars)
					HStack {
						Text("Area")
						TextField(filtervars.searchArea, text: $filtervars.searchArea)
					}
					HStack {
						Text("Name")
						TextField(filtervars.searchTitle, text: $filtervars.searchTitle)
					}
					HStack  {
						DatePicker(	"Start Date",
									selection: $filtervars.searchStartDate,
									displayedComponents: [.date])
							.datePickerStyle(DefaultDatePickerStyle())
					
						
						DatePicker("End Date",
								   selection: $filtervars.searchEndDate,
								displayedComponents: [.date])
							.datePickerStyle(DefaultDatePickerStyle())
					}
				}
				Group {			// requited to overcome 10 view limit
					SliderView(filtervar: $filtervars.searchLength, valueRange: 0.0 ... 500.0, valueString: "Length (miles)", baseMinValue: 0, baseMaxValue: 500)
					SliderView(filtervar: $filtervars.searchPace, valueRange: 0.0 ... 75.0, valueString: "Pace (mph)", baseMinValue: 0, baseMaxValue: 75)
					SliderView(filtervar: $filtervars.searchAscent, valueRange: 0.0 ... 30000.0, valueString: "Ascent (ft)", baseMinValue: 0, baseMaxValue: 30000)
					SliderView(filtervar: $filtervars.searchDescent, valueRange: -20000.0 ... 0, valueString: "Descent (ft)", baseMinValue: -20000, baseMaxValue: 0)
					SliderView(filtervar: $filtervars.searchMaxElevation, valueRange: 0 ... 15000, valueString: "Elevation (ft)", baseMinValue: 0, baseMaxValue: 15000)
					 
					}
				
				Button("Cancel") {
						//self.setStateToDefault()
					self.stateFlag = FlagStates.empty
				}
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

