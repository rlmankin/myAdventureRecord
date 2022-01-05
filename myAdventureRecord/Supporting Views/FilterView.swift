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
	
    var body: some View {

		
		
		timeStampLog(message: "-> FilterView, \(noFilteredAdventures), Length \(filtervars.searchLength.lower), \(filtervars.searchLength.upper)")
		
		return
		
		
			VStack(alignment: .leading) {
					//  present the Button View (category & difficulty).  Since I start with an empty list,
					//		leaving these unset will present no hikes, therefore no additional filters are useful
				FilterButtonsView(filtervars: $filtervars)
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
									selection: $filtervars.searchStartDate,
									displayedComponents: [.date])
							.datePickerStyle(DefaultDatePickerStyle())
					
						
						DatePicker("End Date",
								   selection: $filtervars.searchEndDate,
								displayedComponents: [.date])
							.datePickerStyle(DefaultDatePickerStyle())
					}
				
					FilterSlidersView(filtervars: $filtervars)
				}
				
					 
					
				
				Button("Cancel") {
						//self.setStateToDefault()
					self.stateFlag = FlagStates.empty
				}
		}  // VStack
	}
}


struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
		let filtervars = FilterVars()
		let filteredAdventures = adventureData.filter({$0.hikeCategory == .scenicDrive})
		Group {
			FilterView(filtervars: .constant(filtervars), stateFlag: .constant(FlagStates.showFilterView), noFilteredAdventures: true)
				.padding()
		}
			
    }
}

