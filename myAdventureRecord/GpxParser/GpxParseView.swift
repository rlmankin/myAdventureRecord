//
//  GpxParseView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 2/11/21.
//

import SwiftUI

struct GPXParsingView: View {
	@State  var selectedURLs : [URL] = []
	@State private var selectedTab : Int = 1
	@State private var tabcount : Int = 1
	@State private var firstParse: Bool = true
	@ObservedObject private var parseGPX = parseController()
	private var tabcontent: String = "Working ..."
	
	func createTabContent(validStat: Bool, trackString: String, index: Int) -> String {
		if validStat {
			return "Working ..."
		} else {
			return trackString
		}
	}
	
	var body: some View {
		
		if !selectedURLs.isEmpty {
			
			
			
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
							
							/*VStack {
								
								Text(createTabContent(
											validStat: parseGPX.parsedTracks[track].validTrkptsForStatistics.isEmpty,
											trackString: parseGPX.parsedTracks[track].print(true),
											index: track)
								)
								
							}
							.font(.footnote)
							.tag(track)
							.tabItem { Text("\(parseGPX.parsedTracks[track].header)")}
							.font(.caption)*/
							
						}
					}
					
				}
			}
			
			
		} else {
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
		}
			
		
		
	}
}

