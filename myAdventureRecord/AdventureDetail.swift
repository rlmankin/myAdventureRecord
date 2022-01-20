//
//  AdventureDetail.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/16/20.
//
//  In order to implement a progress view while loading trackpoints, I've had to utilize the @ViewBuilder construct and create a private computed variable <detailview>.  This technique is documented in this link.  https://www.swiftbysundell.com/articles/avoiding-anyview-in-swiftui/

import SwiftUI
import MapKit

struct AdventureDetail: View {
	
	@EnvironmentObject var userData: UserData
	@State var adventure: Adventure				// this is the adventure passed from the Adventure List Navigation link.  This is @State to allow for mutation when the
														//		trackpoint list has not been loaded into the passedAdventure struture
	var beenInserted : Bool								// this is the indicator if the passed adventure has been inserted into the database
	
	// Editing State varialbles, these are private just to this view and it's subviews
	@State private var section2Editing : Bool = false
	@State private var editName : String = "null"
	@State private var editTrackComment : String = "null"
	@State private var editDescription : String = "null"
	@State private var editHikeCategory  = Adventure.HikeCategory.none
	@State private var editArea : String = "Colorado"
	
	var adventureIndex: Int {							// index of the adventure
		userData.adventures.firstIndex(where: { $0.id == adventure.id})!			// this will crash if the adventure array is empty or the passedAdventure.id is not valid
	}
	
	//	a function to load all the temporary edit variable with the existing data, prior to editing
	func loadEditVars() {
		guard !userData.adventures.isEmpty else {
			print("loadEditVars - userData.adventures = 0")
			return
		}
		editName = userData.adventures[adventureIndex].trackData.header
		editTrackComment = userData.adventures[adventureIndex].trackData.trackComment
		editDescription = userData.adventures[adventureIndex].description
		editHikeCategory = userData.adventures[adventureIndex].hikeCategory
		editArea = userData.adventures[adventureIndex].area
	}
	
	//	a function to update the userData with the edited values
	func loadUserDataProperties() {
		guard !userData.adventures.isEmpty else {
			print("loadUserDataProperties - userData.adventures = 0")
			return
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
		_ = trackDb.sqlUpdateAdvRow(rowID, &userData.adventures[adventureIndex])	// update the appropriate row in the adventure table
		_ = trackDb.sqlUpdateTrkRow(rowID, userData.adventures[adventureIndex])		// update the appropriate row in the track table
	}
	
	
	var body: some View {
		
		timeStampLog(message: "AdventureDetail body")
		return detailView
		
	}
	
	//	this is the private computed property that returns the appropriate view (ProgressView or ScrollView) depending on if the passed adventure trackpoint list exists.
	//		this @ViewBuilder technique is the recommeneded way to deal with multiple return conditions that are not of the same view type.  The .task closure allows the
	//		launches an asynchronous task to get the trackpoint list from the database, then complete populating the passed adventure structure.
	@ViewBuilder
	private var detailView : some View {
		if userData.adventures[adventureIndex].trackData.trkptsList.isEmpty {
			VStack {
				Text("Loading trackpoint list for \(adventure.name)")
				ProgressView()
				.task {
					await userData.getTpListfromDb(index: adventureIndex, id: adventure.id)
					if adventure.trackData.trkptsList.isEmpty {
						adventure.trackData.trkptsList = userData.adventures[adventureIndex].trackData.trkptsList
							//	coordinates set the center of the map at the starting location and hold the maximum/minimum latitude/longitude to set the area
							//	of the track.  This is used to set the center and area of the map
						adventure.coordinates.latitude = adventure.trackData.trkptsList[0].latitude
																					//	find the latitude of the start of the track
						adventure.coordinates.longitude = adventure.trackData.trkptsList[0].longitude
																					//	find the longitude of the start of the track
							// find the maximum latitude and longitude.
							//	probably should 'guard' these to avoid an unexpected crash for nil
						adventure.coordinates.maxLatitude = adventure.trackData.trkptsList.compactMap({$0.latitude}).max()!
						adventure.coordinates.maxLongitude = adventure.trackData.trkptsList.compactMap({$0.longitude}).max()!
								// find the minumum latitude and longitude
						adventure.coordinates.minLatitude = adventure.trackData.trkptsList.compactMap({$0.latitude}).min()!
						adventure.coordinates.minLongitude = adventure.trackData.trkptsList.compactMap({$0.longitude}).min()!
								// calculate the 'span' of the latitude and longitude.  This sets the various 'corners' of the map
						adventure.latitudeSpan = CLLocationDegrees( max( abs( adventure.coordinates.latitude - adventure.coordinates.maxLatitude),
													  abs( adventure.coordinates.latitude - adventure.coordinates.minLatitude)))
						adventure.longitudeSpan = CLLocationDegrees(max( abs( adventure.coordinates.longitude - adventure.coordinates.maxLongitude),
													  abs( adventure.coordinates.longitude - adventure.coordinates.minLongitude)))
					}
				}
			}
		} else {
			//	the ScrollView is the guts of the AdventureDetailView...
			ScrollView {
				ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
					// ZStack for the map and 'open in maps' overlay
					MapView(coordinate: adventure.locationCoordinate,
							track: adventure.trackData)
						.frame(height:350)
						.overlay(
							GeometryReader { proxy in
								Button("Open in Maps") {
									let destination = MKMapItem(placemark: MKPlacemark(coordinate: adventure.locationCoordinate))
									destination.name = adventure.name
									destination.openInMaps()
								}
								.frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottomTrailing)
								.offset(x: -10, y: -10)
							}
						)
				}
				
				AdventureSection2View(section2Editing: $section2Editing, editName: $editName, editTrackComment: $editTrackComment, editDescription: $editDescription, editHikeCategory: $editHikeCategory, editArea:  $editArea, adventure: adventure)
					.overlay(
						GeometryReader { proxy in
							Button("\(section2Editing == true ? "Done" : "Edit")") {
								if section2Editing {
									if beenInserted {
										loadUserDataProperties()
										updateDatabases()
									}
								} else {
									loadEditVars()
								}
								section2Editing.toggle()
								
							}.disabled(!beenInserted)
							 .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topTrailing)
							 .offset(x: section2Editing ? -80 : -10, y: 10)
							
							if section2Editing {
								Button("Cancel") {
									section2Editing.toggle()
								}
								.frame(width: proxy.size.width, height: proxy.size.height, alignment: .topTrailing)
								.offset(x: -10, y: 10)
							}
						})
				
				// TabView for graphing buttons
				TabView {
					DistanceElevationTab(adventure: adventure)
						.tabItem({
							Image(systemName: "thermometer")
							Text("Elevation")})//.background(Color.red)
					let adventureSplits = createSplits(trkptsList: adventure.trackData.trkptsList)
					SplitsView(eighthSplits: adventureSplits.eighthSplits, mileSplits: adventureSplits.mileSplits)
						.tabItem({
							Image(systemName: "chart.bar.fill")
							Text("Splits").foregroundColor(.green)
						})
				
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
				}.frame(minWidth: 500, idealWidth: 500, maxWidth: .infinity, minHeight: 400,idealHeight: 700, maxHeight: .infinity, alignment: .center)
			}
		}
	}
}

struct AdventureDetail_Previews: PreviewProvider {
    static var previews: some View {
		AdventureDetail(adventure: adventureData[5], beenInserted: true)
			.environmentObject(UserData())
			.frame(width: 500, height: 1000)
    }
}

