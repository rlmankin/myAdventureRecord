//
//  AdventureSection2View.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 3/18/21.
//

import SwiftUI

struct AdventureSection2View: View {
	@EnvironmentObject var userData: UserData
	@Binding var section2Editing : Bool
	
	// Editing State varialbles
	@Binding var editName : String
	@Binding var editTrackComment : String
	@Binding var editDescription : String
	@Binding var editHikeCategory : Adventure.HikeCategory
	@Binding var editArea : String
	
	

	var adventure: Adventure
	
	var adventureIndex: Int {
		userData.adventures.firstIndex(where: { $0.id == adventure.id}) ?? 0
	}
	
	var associatedTrackIndex: Int {
		userData.adventures.firstIndex(where: { $0.associatedTrackID == adventure.associatedTrackID}) ?? 0
	}
	
	
	
    var body: some View {
		
		print("AdventureSection2View")
		
		return ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
				CircleImage(image: adventure.image.resizable())
					.offset(x:5, y: -135)
					.frame(width: 150, height:150)
			//VStack (2)
				VStack (alignment: .leading, spacing: 0) {
					
					// Vstack for all Text, impages, and graphs
					HStack( alignment: .center, spacing: 12) {
						
		
						if section2Editing {
							Form {
								CategoryPicker("Category", selection: $editHikeCategory)
							}.onAppear { self.editHikeCategory = adventure.hikeCategory}
							.frame(width: 150, height: 150, alignment: .bottom)
						} else {
							Text(adventure.hikeCategory.description)
								.frame(width: 150, height: 150, alignment: .bottom)
						}
						
						//TextField("", text: adventure.hikeCategory.rawValue)
						//	.frame(width: 150,height: 150,  alignment: .bottom)
						VStack(alignment: .center) {
							HStack (alignment: .center) {
								if section2Editing {
									TextField("", text: $editName)
										.onAppear {self.editName = adventure.name}
										.font(.title)
										.foregroundColor(.yellow)
								} else {
									Text(adventure.name).font(.title).italic()
								}
								Button(action: {  // the favorite button can be selected outside of edit mode.  Just need to update the .isFavorite element of the adventure table
									//updateDatabases()
									self.userData.adventures[self.associatedTrackIndex]
										.isFavorite.toggle()
									let trackDb = sqlHikingData
									let rowID = userData.adventures[associatedTrackIndex].trackData.trkUniqueID
									let updatedAdvRow = trackDb.sqlUpdateAdvRow(rowID, &userData.adventures[associatedTrackIndex])
									// updates all field in adventure Table rows associated with this track
									let updatedTrkRow = trackDb.sqlUpdateTrkRow(rowID, userData.adventures[associatedTrackIndex])
									// updates the trackdata.trackComment field in the track Table
									//let retrievedTrack = trackDb.sqlRetrieveRecord(rowID) //	open and connect to the hikingdbTable of the SQL hiking database
									//retrievedTrack?.print()
									print("isFavorite updated - \(self.userData.adventures[self.associatedTrackIndex].isFavorite)")
								}) {
									if userData.adventures[self.associatedTrackIndex].isFavorite {
										Image("star-filled")
											.resizable()
											.renderingMode(.template)
											.accessibility(label: Text("Remove from favorites"))
									} else {
										Image("star-empty")
											.resizable()
											.renderingMode(.template)
											.foregroundColor(.gray)
											.accessibility(label: Text("Add to favorites"))
									}
									
									
								}	//button
								.frame(width: 20, height: 20)		// Need frame to keep star small
								.buttonStyle(PlainButtonStyle())
							}
							HStack {
								DifficultyView(hikeDifficulty: adventure.difficulty)
									.opacity(0.6)
								Text(String(format: "location: %5.3f , %5.3f", adventure.coordinates.latitude,adventure.coordinates.longitude))
									.italic()
									.foregroundColor(.secondary)
								if section2Editing {
									TextField("", text: $editArea)
										.onAppear {self.editArea = adventure.area}
								} else {
									Text(adventure.area)
										.italic()
								}
								
							}.font(.headline)
							
						}
						
					} //HStack
					VStack( alignment: .leading) {
						// Vstack for Description Title and Description
						Divider()
						HStack (alignment: .center, spacing: 20) {
							Text("About: \(adventure.name) - ")
								.italic()
								.font(.headline)
							if section2Editing {
								TextField("", text: $editTrackComment)
									.onAppear {self.editTrackComment = adventure.trackData.trackComment}
									.lineLimit(1)			// doesn't seem to work
									.foregroundColor(.green)
									.font(.headline)
							} else {
								if adventure.trackData.trackComment.isEmpty {
									Spacer()
								}
								Text(adventure.trackData.trackComment)
										.foregroundColor(.green)
										.font(.headline)
							}
							if let x = adventure.trackData.trackSummary.startTime {
								Text(x, style: .date).padding(.trailing, 30)
							}
							
							
						}.frame(height: 30)
						if section2Editing {
							TextEditor(text: $editDescription)
								.onAppear {self.editDescription = adventure.description}
								.lineLimit(3)
								.offset(x:10)
								.foregroundColor(.green)
								.frame(minWidth: 400, idealWidth: 810, maxWidth: 810, minHeight: 0, idealHeight: 30, maxHeight: 50, alignment: .leading)
						} else {
							Text(adventure.description)
								.offset(x:10)
								.foregroundColor(.green)
								.frame(minWidth: 400, idealWidth: 810, maxWidth: 810, minHeight: 0, idealHeight: 30, maxHeight: 50, alignment: .leading)
						}
					}.offset(x:10)
					
				} //VStack (2)
			} // ZStack
		
    }
}

struct AdventureSection2View_Previews: PreviewProvider {
    static var previews: some View {
		AdventureSection2View(section2Editing: .constant(false),
							  editName: .constant("null"),
							  editTrackComment: .constant("null"),
							  editDescription: .constant("null"),
							  editHikeCategory: .constant(Adventure.HikeCategory.none),
							  editArea: .constant("null)"),
							  adventure: adventureData[0])
				.environmentObject(UserData())
				.frame(width: 850, height: 900)
		
		AdventureSection2View(section2Editing: .constant(true),
							  editName: .constant("null"),
							  editTrackComment: .constant("null"),
							  editDescription: .constant("null"),
							  editHikeCategory: .constant(Adventure.HikeCategory.none),
							  editArea : .constant("null"),
							  adventure: adventureData[0])
				.environmentObject(UserData())
				.frame(width: 850, height: 900)
    }
}
