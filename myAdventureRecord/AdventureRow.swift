//
//  AdventureRow.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/7/20.
//

import SwiftUI

struct AdventureRow: View {
	var adventure: Adventure
	
	
	var body: some View {
		HStack(alignment: .center) {
			adventure.image
				.resizable()
				.frame(width: 40, height: 40)
				.cornerRadius(4.0)
			
			VStack(alignment: .leading) {
				HStack (spacing: 4) {
					VStack (alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/ ) {
						Text(adventure.hikeCategory.description)
							.italic()
							.font(.callout)
							.multilineTextAlignment(.center)
						if adventure.isFavorite {
							Image(systemName: "star.fill")
								.foregroundColor(.yellow)
						}
						
					}.frame(width: 75, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
					
					
					VStack (alignment: .leading) {
						HStack (spacing: 2) {
						 
							Text(adventure.name + "(\(adventure.trackData.trkUniqueID))")
								.foregroundColor(  adventure.trackData.trkptsList.isEmpty ? .yellow : .green)
							.bold()
							.italic()
							.truncationMode(.tail)
							.frame(width: 250, alignment: .leading)
						
							Image(systemName: "circle.fill")
								.resizable()
								.frame(width: 10, height: 10)
								.foregroundColor(adventure.difficulty)
						}
						HStack {
							Text(adventure.area)
								.font(.caption)
								.frame(width: 50)
							Text(adventure.hikeDate)
								.font(.caption)
							Text(adventure.trackData.trackComment)
								.font(.caption)
								.opacity(0.625)
								.truncationMode(.middle)
							
						}
							
					}
				}
				

				
			} //vstack
			.font(.body)
			
		}
		.padding(.vertical, 4)		//hstack
    }
}

struct AdventureRow_Previews: PreviewProvider {
    static var previews: some View {
		AdventureRow(adventure: adventureData[0])
    }
}
