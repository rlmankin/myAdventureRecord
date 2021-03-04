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
			//Text(String(format: " %3d, %3d", adventure.trackData.trkptsList.count, adventure.id-1))
			//	.frame(width: 55, alignment: .leading)
			
			adventure.image
				.resizable()
				.frame(width: 25, height: 25)
				.cornerRadius(4.0)
			
			VStack(alignment: .leading) {
				HStack (spacing: 2) {
					if adventure.isFavorite {
						Image(systemName: "star.fill")
							.foregroundColor(.yellow)
					}
					VStack (alignment: .leading) {
						HStack (spacing: 2) {
						 
							Text(adventure.name)
							.foregroundColor(.green)
							.bold()
							.italic()
							.truncationMode(.tail)
							.frame(width: 250, alignment: .leading)
						
							Image(systemName: "circle.fill")
								.resizable()
								.frame(width: 10, height: 10)
								.foregroundColor(adventure.difficulty)
							
							
							Text("(\(adventure.trackData.trkptsList.count))")
								.font(.caption)
								.frame( alignment: .center)
						}
						HStack {
							Text(adventure.hikeDate)
								.font(.caption)
							Text(adventure.trackData.trackComment + "blah")
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
		AdventureRow(adventure: adventureData[5])
    }
}
