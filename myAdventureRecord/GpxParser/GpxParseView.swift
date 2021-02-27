//
//  GpxParseView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 2/11/21.
//

import SwiftUI

struct GPXParsingView: View {
	@EnvironmentObject var userData: UserData
	@EnvironmentObject var parseGPX :  parseController
	@State  var selectedURLs : [URL] = []
	@State private var selectedTab : Int = 0
	@State private var tabcount : Int = 1
	
	@State private var tabInserted: [Bool] = [false]
	@Binding var showingParseDetail : Adventure?
	@Binding  var firstParse: Bool
	@Binding var parseFile : Bool
	
	func testTab() -> Bool {													// simple function to test if the tabInserted[selectedTab] is valid.  Needed due to compiler
		return selectedTab < tabInserted.count ? tabInserted[selectedTab] : false	// limitations on type checking
	}
	
	var body: some View {
		//Text(String(selectedTab))
		//Text(String(firstParse))
		//if !selectedURLs.isEmpty {
		//if !firstParse {
			if parseGPX.numberOfTracks != 0 {
				TabView (selection: $selectedTab) {
					if parseGPX.parsedTracks.count != 0 {
						ForEach( 0 ... parseGPX.parsedTracks.count - 1, id:\.self) {track in
							if parseGPX.parsedTracks[track].validTrkptsForStatistics.isEmpty {
								
								ProgressView()
									.font(.footnote)
									.tag(track)
									.tabItem { Text("\(parseGPX.parsedTracks[track].header)")}
									.font(.caption)
							} else {
								Text(parseGPX.parsedTracks[track].print(true))
									.font(.footnote)
									.tag(track)
									.tabItem { Text("\(parseGPX.parsedTracks[track].header)")}
									.font(.caption)
							}
						}
					}
				}.toolbar {
					ToolbarItemGroup (placement: .status) {
							   Button("DbInsert") {
									print("Insert selected \(parseGPX.numberOfTracks)")
									let trackDb = SqlHikingDatabase()
									let x = trackDb.sqlInsertDbRow(parseGPX.parsedTracks[selectedTab])
									let trkptDb = SqlTrkptsDatabase()
									let y = trkptDb.sqlInsertTrkptList(x, parseGPX.parsedTracks[selectedTab].trkptsList)
									print(x, y )
									
									userData.add(parseGPX.parsedTracks[selectedTab])
							
								
									
									tabInserted[selectedTab].toggle()
							}.disabled( testTab() )
						
								Button("showDetail") {
									showingParseDetail = loadAdventureTrack(track: parseGPX.parsedTracks[selectedTab])
								}
						   
						}
				}
			} else {
				Text(String(parseGPX.numberOfTracks) + String(firstParse))
			}
	/*	} else {
			Text("")
				.fileImporter(isPresented: .constant(true),
								allowedContentTypes: [.xml],
								allowsMultipleSelection: true)
					{result in
					   do {
							let fileURLs = try result.get()
							 selectedURLs = fileURLs
							 print(selectedURLs)
							 let parseFilesSuccess = parseGPX.parseGpxFileList(selectedURLs)
							firstParse = false
					   } catch {
						   print("Fail")
					   }
				   }
		}*/
			
		
		
	}
}

