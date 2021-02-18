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
	
	/* func parseAll(urlArray: [URL]) -> Bool {
		var trackArray : [Track] = []
		
		if firstParse {
			
			for url in 0 ... urlArray.count - 1  {
				
					parseGPX.parseURL(gpxURL: urlArray[url])
					print("\(urlArray[url].lastPathComponent), trackCount = \(parseGPX.allTracks.count)")
					
				
			}
		}
		return true
		//return parseGPX.allTracks
	}*/
	
	var body: some View {
		
		if !selectedURLs.isEmpty {
			
			
			if parseGPX.parsedTracks.count != 0 {
				TabView {
					ForEach( 0 ... parseGPX.parsedTracks.count - 1, id:\.self) {track in
						VStack {
							Text("\(parseGPX.parsedTracks[track].header)+ \(track)")
							Text(parseGPX.parsedTracks[track].print(true))
						}
						.font(.footnote)
						.tag(track)
						.tabItem { Text("\(parseGPX.parsedTracks[track].header)")}
							.font(.caption)
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

