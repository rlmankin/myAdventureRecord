//
//  AdventureDetail.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/16/20.
//

import SwiftUI
import MapKit

struct AdventureDetail: View {
	
	@EnvironmentObject var userData: UserData
	@State private var section2Editing : Bool = false
	
	// Editing State varialbles
	@State private var editName : String = "null"
	@State private var editTrackComment : String = "null"
	@State private var editDescription : String = "null"
	@State private var editHikeCategory  = Adventure.HikeCategory.none
	@State private var editArea : String = "Colorado"
	
	
	

	var adventure: Adventure
	//  Need to watch the tabInserted[] from GPXParseView to know if a track has been
	//	inserted into the database
	var beenInserted : Bool
	
	var adventureIndex: Int {
		userData.adventures.firstIndex(where: { $0.id == adventure.id})!
	}
	
	func loadEditVars() {
		editName = userData.adventures[adventureIndex].trackData.header
		editTrackComment = userData.adventures[adventureIndex].trackData.trackComment
		editDescription = userData.adventures[adventureIndex].description
		editHikeCategory = userData.adventures[adventureIndex].hikeCategory
		editArea = userData.adventures[adventureIndex].area
	}
	
	func loadUserDataProperties() {
		for item in (0 ... userData.adventures.count - 1) {
			print("userData.adventures[\(item)] - \(userData.adventures[item].id),\(userData.adventures[item].associatedTrackID),\(userData.adventures[item].name), \(userData.adventures[item].trackData.header)")
		}
		userData.adventures[adventureIndex].trackData.header = editName // editName is duplicated
		userData.adventures[adventureIndex].name = editName				// in both the adventure
											// name and in the track header.  Make sure to change
											//	both
		userData.adventures[adventureIndex].trackData.trackComment = editTrackComment
		userData.adventures[adventureIndex].description = editDescription
		userData.adventures[adventureIndex].hikeCategory =  editHikeCategory
		userData.adventures[adventureIndex].area = editArea
	}
	
	func updateDatabases() {
		
		// function to update all database tables potentially changed during a edit session of AdventureDetail/AdventureSection2View
		//  the track table row is unique to each track in the track table.  This value is used in the AssociatedTrackID field in
		//	both the trackpoints table and the adventure table to link the correct track to the lists of trackpoints and the adventure
		// Note:  because it is possible that userData may be sorted, just using the array index of the adventure is not appropriate
		//	we must use the row of the track in the database.  As indicated this row# is stored in the adventure table and trackpoints table
		//	as the field AssociatedTrackID
		// This function is global to enable single point changes.
		
		let trackDb = sqlHikingData											// create/open the hiking database
		let rowID = userData.adventures[adventureIndex].trackData.trkUniqueID		// trkUniqueID is the row in the hikingdbTable where the track is stored
		let updatedAdvRow = trackDb.sqlUpdateAdvRow(rowID, &userData.adventures[adventureIndex])	// update the appropriate row in the adventure table
		let udatedTrkRow = trackDb.sqlUpdateTrkRow(rowID, userData.adventures[adventureIndex])		// update the appropriate row in the track table
	}
	
	var body: some View {
		
		print("AdventureDetail body")
		
		
		return ScrollView  {
			ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
				// ZStack for the map and 'open in maps' overlay
				
				MapView(coordinate: adventure.locationCoordinate,
						track: adventure.trackData)
					.frame(height:350)
					.overlay(
						GeometryReader { proxy in
							Button("Open in Maps") {
								let destination = MKMapItem(placemark: MKPlacemark(coordinate: self.adventure.locationCoordinate))
								destination.name = self.adventure.name
								destination.openInMaps()
							}
							.frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottomTrailing)
							.offset(x: -10, y: -10)
						}
					)
				//CircleImage(image: adventure.image.resizable())
				//	.offset(x:5, y: 135)
					
				//	.frame(width: 150, height:150)
				
			}
			
			AdventureSection2View(section2Editing: $section2Editing, editName: $editName, editTrackComment: $editTrackComment, editDescription: $editDescription, editHikeCategory: $editHikeCategory, editArea:  $editArea, adventure: adventure)
				.overlay(
					GeometryReader { proxy in
						
						Button("\(section2Editing == true ? "Done" : "Edit")") {
							if section2Editing {
								print( "do the userData and database updates here")
								if beenInserted {
									loadUserDataProperties()
									updateDatabases()
								}
							} else {
								loadEditVars()
							}
							section2Editing.toggle()
							
						}
						.frame(width: proxy.size.width, height: proxy.size.height, alignment: .topTrailing)
						.offset(x: section2Editing ? -80 : -10, y: 10)
						
						if section2Editing {
							Button("Cancel") {
								section2Editing.toggle()
							}.frame(width: proxy.size.width, height: proxy.size.height, alignment: .topTrailing)
							.offset(x: -10, y: 10)
						
						}
					})
			
			
			
			// TabView for graphing buttons
			TabView {
				DistanceElevationTab(adventure: adventure)
					.tabItem({
								Image(systemName: "thermometer")
								Text("Elevation")})//.background(Color.red)
				DistanceGradeTab(adventure: adventure)
					.tabItem({
								Image(systemName: "chart.bar.fill")
								Text("Grade")})
				DistanceSpeedTab(adventure: adventure)
					.tabItem({
								Image(systemName: "chart.bar.fill")
								Text("Speed")})
				SummaryTab(adventure: adventure)
					.tabItem({
						Image(systemName: "chart.bar.fill")
						Text("Summary")
					})
				
			}.frame(minWidth: 500, idealWidth: 500, maxWidth: .infinity, minHeight: 0/*@END_MENU_TOKEN@*/, idealHeight: 400, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center)
			
			
			
			
		}  // Scrollview
		//.frame(minWidth: 500, idealWidth: 500, maxWidth: .infinity, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 400, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
}

struct AdventureDetail_Previews: PreviewProvider {
    static var previews: some View {
		AdventureDetail(adventure: adventureData[0], beenInserted: true)
			.environmentObject(UserData())
			.frame(width: 850, height: 900)
    }
}
}
