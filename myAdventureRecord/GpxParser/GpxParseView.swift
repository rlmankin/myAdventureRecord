//
//  GpxParseView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 2/11/21.
//

import SwiftUI
//import Foundation

struct ParsingProgressView: View {
	
	
	var body: some View {
		ProgressView()
	}
}

struct GPXParsingView: View {
	@EnvironmentObject var userData: UserData
	@EnvironmentObject var parseGPX :  parseController
	
	@State  var selectedURLs : [URL] = []
	@State private var selectedTab : Int = 0
	@State private var tabInserted: [Bool] = [false]
	
	
	// simple function to test if the tabInserted[selectedTab] is valid.  Needed due to compiler limitations on type checking
	func testForValidTab() -> Bool {
		return selectedTab < tabInserted.count ? tabInserted[selectedTab] : false
	}
	
	var body: some View {
			
			//  if there were no GPX tracks found in the requested URL, then generate a Text view to tell user something is amiss
			//		likely a non-GPX XML file.
			if parseGPX.numberOfTracks != 0 {
				//	make a tabview of all the tracks found in the set of parses
				TabView (selection: $selectedTab) {						//	allow the user to select tabs - $selectedTab
					if parseGPX.parsedTracks.count != 0 {
						//	loop through each track and display the relevant track detail information
						ForEach( 0 ... parseGPX.parsedTracks.count - 1, id:\.self) {track in
							//	if the validTrkprtsForStatistics array is empty implies that the track is still being parsed,
							//		so show a progress wheel.  Note: to make this work, I changed the parseGPXXML to do a two-pass parse
							//		the first pass to find all the tracks and corresponding header (if any) in the file,
							//		the second to actually parse and gather statistics
							if parseGPX.parsedTracks[track].validTrkptsForStatistics.isEmpty {
								ParsingProgressView()
									.tabItem { Text("\(parseGPX.parsedTracks[track].header)")}
							} else {
								//	the track has finishing parsing, so make an 'adventure' out of it and display the detail view
								if userData.adventures.count == 0 {
									Text(parseGPX.parsedTracks[track].print())
								} else {
									AdventureDetail(adventure: loadAdventureTrack(track: parseGPX.parsedTracks[track]), beenInserted: tabInserted[selectedTab])
										.tag(track)
										.tabItem { Text("\(parseGPX.parsedTracks[track].header)")}
								}
							}
						}
					}
				}
				//	associated with each track having been parsed, allow the user to insert that track into the SQL Hiking Database
				.toolbar {
					//	this toolbarItem / button snippet places the insert into the detail view toolbar status area
					ToolbarItemGroup (placement: .status) {
						Button("DbInsert") {
							// this is an initial insert of a parsedTrack into all tables in the database
							
							
							let trackDb =   sqlHikingData		//	open and connect to the hinkingdbTable of the SQL hiking database
							trackDb.sqlInsertToAllTables(track: parseGPX.parsedTracks[selectedTab])
							//let trackRow = trackDb.sqlInsertDbRow(parseGPX.parsedTracks[selectedTab])
							//let trkptRow = trackDb.sqlInsertTrkptList(trackRow, parseGPX.parsedTracks[selectedTab].trkptsList)
							//let tempTrack = parseGPX.parsedTracks[selectedTab]
							//let tempAdv = loadAdventureTrack(track: tempTrack)
							//let advRow = trackDb.sqlInsertAdvRow(trackRow, tempAdv)
							//print(x, y )
							
							userData.reload()
							//userData.add(parseGPX.parsedTracks[selectedTab])	// append the selected track into the datbase							tabInserted[selectedTab].toggle()		// disable the "insertDB" button to keep the user from adding the same parse many times
						}.buttonStyle(DetailButtonStyle())
						 .disabled( testForValidTab() )
					}
				}
			} else {
				Text(" number of Track is \(parseGPX.numberOfTracks).  Likely a non-GPX XML file")
			}
	}
}

