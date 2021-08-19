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

struct whichAdventureView : View {
	@EnvironmentObject var userData: UserData
	@EnvironmentObject var parseGPX :  parseController
	
	var trackIndex : Int
	var beenInserted : Bool
	
	var body: some View {
		
			//print("->whichAdventureView \(trackIndex), \(beenInserted), \(parseGPX.parsedTracks[trackIndex].trkUniqueID)")
			// if the track has already been inserted into the Database, then it's index will be found in userData.adventures and
			//	we can call AdventureDetail with the userData information
			// otherwise we need to call AdventureDetail with the parsed track information in parseGPX
		
		return Group {
				if let userDataTrackIndex = userData.adventures.firstIndex(where: {($0.id == parseGPX.parsedTracks[trackIndex].trkUniqueID)}) {
					AdventureDetail(passedAdventure: userData.adventures[userDataTrackIndex],  beenInserted: true)
						.tag(trackIndex)
						.tabItem { Text("\(parseGPX.parsedTracks[trackIndex].header)")}
				} else {
					AdventureDetail(passedAdventure: loadAdventureTrack(track: parseGPX.parsedTracks[trackIndex]), beenInserted: false)
						.tag(trackIndex)
						.tabItem { Text("\(parseGPX.parsedTracks[trackIndex].header)")}
				}
		}
	}
}



struct GPXParsingView: View {
	@EnvironmentObject var userData: UserData
	@EnvironmentObject var parseGPX :  parseController
	
	@State  var selectedURLs : [URL] = []
	@State private var selectedTab : Int = 0
	
	var body: some View {
		timeStampLog(message: "-> GPXParsingView")
	
			//  if there were no GPX tracks found in the requested URL, then generate a Text view to tell user something is amiss
			//		likely a non-GPX XML file.
		return Group {
			if parseGPX.numberOfTracks != 0 {
				
				
				//	make a tabview of all the tracks found in the set of parses
				TabView (selection: $selectedTab) {						//	allow the user to select tabs - $selectedTab
					
					if !parseGPX.parsedTracks.isEmpty {
						
						//	loop through each track and display the relevant track detail information
						ForEach( 0 ..< parseGPX.parsedTracks.endIndex, id:\.self) {trackIndex in
							
							//	when the validTrkprtsForStatistics array is empty, it implies that the track is still being parsed,
							//		so show a progress wheel.  Note: to make this work, I changed the parseGPXXML to do a two-pass parse
							//		the first pass to find all the tracks and corresponding header (if any) in the file,
							//		the second to actually parse and gather statistics
							
							if !parseGPX.parsedTracks[trackIndex].noValidEle {
								if parseGPX.parsedTracks[trackIndex].validTrkptsForStatistics.isEmpty {
									//## bookmark parsing progressView
									ParsingProgressView()
										.tabItem { Text("\(parseGPX.parsedTracks[trackIndex].header)")}
								} else {
									//	the track has finishing parsing, so make an 'adventure' out of it and display the detail view
									whichAdventureView(trackIndex: trackIndex, beenInserted: false )
								}
							} else {
								Text("no valid ele")
									.tabItem{ Text("\(parseGPX.parsedTracks[trackIndex].header)")}
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
							
							print("inserting adventure into Db")
							let trackDb =   sqlHikingData		//	open and connect to the hinkingdbTable of the SQL hiking database
							// setting the trkUniqueID places the database rowID where the track was inserted to be available
							//	to AdventureDetail when it is updated.  This is necessary inorder to insure that edit done after
							//	insertion but before navigating away from the detail view will be captured.
							parseGPX.parsedTracks[selectedTab].trkUniqueID = Int(trackDb.sqlInsertToAllTables(track: parseGPX.parsedTracks[selectedTab]))
							userData.append(item: parseGPX.parsedTracks[selectedTab])
							//trackDb.reloadTracks()
							
							//userData.reload()
						}.buttonStyle(DetailButtonStyle()) // disable the "insertDB" button to keep the user from adding the same parse many times
						 .disabled( userData.adventures.firstIndex(where: {($0.id == parseGPX.parsedTracks[selectedTab].trkUniqueID)}) != nil)
						
					}
				}
			} else {
				Text(" number of Track is \(parseGPX.numberOfTracks).  Likely a non-GPX XML file")
			}
		}
	}
}

