//
//  FilterButtonsView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 12/24/21.
//

import SwiftUI

let difficultyCases = [Color.green, Color.blue, Color.yellow, Color.orange, Color.red, Color.gray]

struct FilterButtonsView: View {
	@Binding var filtervars: FilterVars
	
	
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
	
    var body: some View {
		
		HStack {
			Spacer()
			Text("Type")
				.font(.headline)
			Spacer()
		}
		HStack {
			Spacer()
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
				//Button("all",
				//	   action: { filtervars.filterByDifficulty = (score:0.0,color:Color.gray)})
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


struct FilterButtonsView_Previews: PreviewProvider {
 
    static var previews: some View {
		let filtervars = FilterVars()
		FilterButtonsView(filtervars: .constant(filtervars))
    }
}
