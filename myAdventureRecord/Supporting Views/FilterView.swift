//
//  FilterView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 9/28/21.
//

import SwiftUI


struct FilterView: View {
	@EnvironmentObject var userData: UserData
	@Binding var filtervars: FilterVars
	@Binding var stateFlag : FlagStates?
	var noFilteredAdventures : Bool
	
	@State private var startDate : Date = { let df = DateFormatter()
										df.dateFormat = "MM/dd/yyyy"
									   if let theDate = df.date(from: "01/01/2013") {
										 return theDate
									   } else {
										 return Date()
									   }
							   }()
	@State private var endDate : Date = Date.now
	@State private var allCategories : Bool = false
	@State private var allDifficulties : Bool = false
	
	init(filtervars : Binding<FilterVars>,
		 stateFlag : Binding<FlagStates?>,
		 noFilteredAdventures : Bool) {
		
		self._filtervars = filtervars
		self._stateFlag = stateFlag
		self.noFilteredAdventures = noFilteredAdventures
	}
	
	
	
    var body: some View {
		
		let boundStartDate = Binding(
								get: {self.startDate},
								set: {self.startDate = $0}
								)
		let boundEndDate = Binding(
								get: {self.endDate},
								set: {self.endDate = $0}
								)
		
		return
		
			VStack(alignment: .leading) {
					//  present the Button View (category & difficulty).  Since I start with an empty list,
					//		leaving these unset will present no hikes, therefore no additional filters are useful
				FilterButtonsView(filtervars: $filtervars, allCategories: $allCategories, allDifficulties: $allDifficulties)
				if noFilteredAdventures {						// no hikes to present
					EmptyView()
				} else {											// add in the additional filters
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
									selection: boundStartDate,
									displayedComponents: [.date])
							.datePickerStyle(DefaultDatePickerStyle())
							.onChange(of: startDate) { value in
								if value <= filtervars.searchDateRange.filterRange.upperBound {
									filtervars.searchDateRange.filterRange = value ... filtervars.searchDateRange.filterRange.upperBound
								}
							}
						
						DatePicker("End Date",
								   selection: boundEndDate,
								displayedComponents: [.date])
							.datePickerStyle(DefaultDatePickerStyle())
							.onChange(of: endDate) { value in
								if value >= filtervars.searchDateRange.filterRange.lowerBound {filtervars.searchDateRange.filterRange = filtervars.searchDateRange.filterRange.lowerBound ... value
								}
							}
					}
					FilterSlidersView(filtervars: $filtervars)
				}
				
				HStack {
					Button("Cancel") {
						filtervars = FilterVars()			// initializes the filter
						self.stateFlag = FlagStates.empty	// return to the top view
					}
					
					Button("Close") {						// keep the existing filter
						self.stateFlag = FlagStates.empty	// return to the top view with filter in place
					}
					
					Button("Clear") {
						filtervars = FilterVars()			// initilizes the filter
						filtervars.filterByCategory = []	// clears the categories
						filtervars.filterByDifficulty = []	// clears the difficulty
						allCategories = false
						allDifficulties = false
						self.stateFlag = FlagStates.showFilterView	// stay in the filterview
					}
				}
				
		}  // VStack
	}
	
}


struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
		let filtervars = FilterVars()
		Group {
			FilterView(filtervars: .constant(filtervars), stateFlag: .constant(FlagStates.showFilterView), noFilteredAdventures: true)
				.environmentObject(UserData())
				.padding()
		}
			
    }
}

