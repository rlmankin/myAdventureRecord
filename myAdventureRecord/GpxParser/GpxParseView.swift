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
	@State private var beenParsed: Bool = false
	
	func parseAll(urlArray: [URL]) -> [Track] {
		var trackArray : [Track] = []
		for url in urlArray {
			let parseGPX = parseGPXXML()
			let parseSuccess = parseGPX.parseURL(gpxURL: url)
			if parseSuccess {
				for  track in (0 ... parseGPX.allTracks.count - 1) {
					trackArray.append(parseGPX.allTracks[track])
				}
			}
		}
		return trackArray
	}
	
	var body: some View {
		
		if !selectedURLs.isEmpty {
			
			let parsedTracks = parseAll(urlArray: selectedURLs)
			var trackcount : Int = 0
			
			TabView(selection: $selectedTab) {
				ForEach (0 ... parsedTracks.count - 1, id:\.self)
					{ track in
							let header = parsedTracks[track].header
							Text( parsedTracks[track].print(true))
								.font(.footnote)
								.tag(track)
								.tabItem { Text("\(parsedTracks[track].header)")}
									.font(.caption)
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
							   } catch {
								   print("Fail")
							   }
						   }
		}
			
		
		
	}
}

