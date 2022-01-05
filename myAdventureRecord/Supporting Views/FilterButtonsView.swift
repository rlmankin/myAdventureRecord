//
//  FilterButtonsView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 12/24/21.
//

import SwiftUI

let difficultyCases = [Color.green, Color.blue, Color.yellow, Color.orange, Color.red, Color.gray]

struct FilterButtonsView: View {
	
	@EnvironmentObject var userData: UserData
	@Binding var filtervars: FilterVars
	@State private var allCategories : Bool = false
	@State private var allDifficulties : Bool = false
	
	
	// populate the button category array
	@State private var categoryButtonActive : [Adventure.HikeCategory: Bool] = {
		var tempDict : [Adventure.HikeCategory: Bool] = [:]
		for key in Adventure.HikeCategory.allCases {
			tempDict[key] = false
		}
		return tempDict
	}()
	
	// populate the button difficulty array
	@State private var difficultyButtonActive : [Color: Bool] = {
		var tempDict : [Color: Bool] = [:]
		for key in difficultyCases {
			tempDict[key] = false
		}
		return tempDict
	}()
	
	// change the various search parameters to reflect the range in the selected adventures
	func setSearchParameter( adventures : [Adventure], mapClosure : (Adventure) -> Double) -> FilterRange {
		let low : Double  = (adventures.map(mapClosure).min()
							?? adventureData.map(mapClosure).min() ?? 0)/metersperMile
		var high : Double  = (adventures.map(mapClosure).max()
							 ?? adventureData.map(mapClosure).max() ?? 804672)/metersperMile
		var range = FilterRange()
		 range.lower = low
		 range.upper = high
		return range
	}
	
	// filter out all adventures that don't math the category or difficulty requested
	func getAdventureSearchResults() -> [Adventure] {
		
		var searchAdventures = userData.adventures
		let categoryIntersection = Array(Set(searchAdventures.map({$0.hikeCategory})).intersection(filtervars.filterByCategory))
		searchAdventures =  searchAdventures.filter { categoryIntersection.contains( $0.hikeCategory)}
		
		let difficultyIntersection = Array(Set(searchAdventures.map({$0.difficulty.color})).intersection(filtervars.filterByDifficulty))
		searchAdventures = searchAdventures.filter { difficultyIntersection.contains( $0.difficulty.color)}
		timeStampLog(message: "->searchAdventures.count \(searchAdventures.count)")
		return searchAdventures
	}
	
    var body: some View {
		timeStampLog(message: "-> FilterButtonsView")
		
				//  custom binding for "all" category Toggle
		let categoryBinding = Binding(
			get: {self.allCategories},
			set: {
				self.allCategories = $0
				filtervars.filterByCategory.removeAll()
				if $0 == true {
					
					for category in Adventure.HikeCategory.allCases {
						filtervars.filterByCategory.append(category)
						categoryButtonActive[category] = true
					}
				} else {
					for category in Adventure.HikeCategory.allCases {
						categoryButtonActive[category] = false
					}
				}
			})
		
				//	custom binding for "all" difficulty Toggle
		let difficultyBinding = Binding(
			get: {self.allDifficulties},
			set: {
				self.allDifficulties = $0
				filtervars.filterByDifficulty.removeAll()
				if $0 == true {
					
					for difficulty in difficultyCases {
						filtervars.filterByDifficulty.append(difficulty)
						difficultyButtonActive[difficulty] = true
					}
				} else {
					for difficulty in difficultyCases {
						difficultyButtonActive[difficulty] = false
					}
				}
			})
		return
		
			Group {
				HStack {
					Spacer()
					Text("Type")
						.font(.headline)
					Spacer()
				}
				HStack {
					Spacer()
					Toggle(isOn: categoryBinding) {					// uses the custom Binding for category
						Text("all")
					}
					ForEach ( Adventure.HikeCategory.allCases, id: \.self) { category in
							Button(category.description,
								   action: {
										if filtervars.filterByCategory.contains(category) {
												// the category has already been selected, so remove it and
												//	set button opacity to fully opaque (1)
											filtervars.filterByCategory.remove(at: filtervars.filterByCategory.firstIndex(of: category)!)
											categoryButtonActive[category] = false
										} else {
												// the category has not been selected, so add it and set
												//	button opacity to 20% to indicate that the category
												//	has been selected
											filtervars.filterByCategory.append(category)
											categoryButtonActive[category] = true
											
										}
										// find the adventures that meet the category requirements
										let searchAdventures = getAdventureSearchResults()
										// find the min/max of the various sliders
										filtervars.searchLength = setSearchParameter(adventures: searchAdventures, mapClosure: {$0.distance})
										timeStampLog(message: "capture search results")
									}
							).opacity(categoryButtonActive[category]! ? 1.0 : 0.5)
						}
					
					Spacer()
				}
				Group {
					HStack {
						Spacer()
						Text("Difficulty")
							.font(.headline)
						Spacer()
					}
					
					HStack {
						Spacer()
						Toggle(isOn: difficultyBinding) {			// uses the custom Binding for difficulty
							Text("all")
						}
						ForEach ( difficultyCases, id: \.self) { difficulty in
							Button(difficulty.description,
								   action: {
										if filtervars.filterByDifficulty.contains(difficulty) {
											filtervars.filterByDifficulty.remove(at: filtervars.filterByDifficulty.firstIndex(of: difficulty)!)
											difficultyButtonActive[difficulty] = false
										} else {
											filtervars.filterByDifficulty.append(difficulty)
											difficultyButtonActive[difficulty] = true
										}
										// find the adventures that meet the category requirements
										let searchAdventures = getAdventureSearchResults()
										// find the min/max of the various sliders
										filtervars.searchLength = setSearchParameter(adventures: searchAdventures, mapClosure: {$0.distance})
										timeStampLog(message: "capture search results")
									}
							)
							//filtervars.filterByDifficulty = (score: 0.0, color: difficulty)})
							.background(difficulty)
							.opacity(difficultyButtonActive[difficulty]! ? 1.0 : 0.5)
								
						}
						Spacer()
					}
				}
			}
    }
}


struct FilterButtonsView_Previews: PreviewProvider {
 
    static var previews: some View {
		let filtervars = FilterVars()
		FilterButtonsView(filtervars: .constant(filtervars))
    }
}
