//
//  DifficultyView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 3/3/21.
//

import SwiftUI

struct DifficultyView: View {
	var hikeDifficulty : (score: Double, color: Color)
	let difficultyCases = [Color.green, Color.blue, Color.yellow, Color.orange, Color.red]
	
	func findColor(difficulty: Color) -> [Color] {
		if let difficultyIndex = difficultyCases.firstIndex(of: difficulty) {
				return Array(difficultyCases[0...difficultyIndex])
		} else {
			return difficultyCases
		}
	}
	
	func findHeight(difficulty: Color) -> CGFloat {
		return CGFloat( ((difficultyCases.firstIndex(of: difficulty)! + 1)*10))
	}
	
	var body: some View {
		
		timeStampLog(message: "-> DifficultyView")
		return VStack (spacing: 0){
			
			
			 
			Rectangle()
				.fill(LinearGradient(gradient: Gradient(colors: findColor(difficulty: hikeDifficulty.color)), startPoint: .bottom, endPoint: .top))
				.frame(width: 30, height: findHeight(difficulty: hikeDifficulty.color), alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
				.overlay( Text("\(String(format: "%3.0f", hikeDifficulty.score))")
							.foregroundColor(Color.white))
				
			
			
		}
    }
}

struct DifficultyView_Previews: PreviewProvider {
    static var previews: some View {
		DifficultyView(hikeDifficulty:(200.0, Color.red))
    }
}
