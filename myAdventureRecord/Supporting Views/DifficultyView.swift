//
//  DifficultyView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 3/3/21.
//

import SwiftUI

struct DifficultyView: View {
	var hikeDifficulty : Color
	let baseColor = [Color(.green), Color(.blue), Color(.yellow), Color(.orange), Color(.red)]
	
	func findColor(difficulty: Color) -> [Color] {
		
		return Array(baseColor[0...baseColor.firstIndex(of: difficulty)!])
	}
	
	func findHeight(difficulty: Color) -> CGFloat {
		
		
		
		return CGFloat( ((baseColor.firstIndex(of: difficulty)! + 1)*10))
	}
    var body: some View {
		
		timeStampLog(message: "DifficultyView")
		return VStack (spacing: 0){
			
			
			 
			Rectangle()
				.fill(LinearGradient(gradient: Gradient(colors: findColor(difficulty: hikeDifficulty)), startPoint: .bottom, endPoint: .top))
				.frame(width: 30, height: findHeight(difficulty: hikeDifficulty), alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
				
			
			
		}
    }
}

struct DifficultyView_Previews: PreviewProvider {
    static var previews: some View {
		DifficultyView(hikeDifficulty:Color(.blue))
    }
}
