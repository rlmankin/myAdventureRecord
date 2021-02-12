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
	
	
	
	var body: some View {
		
		if !selectedURLs.isEmpty {
			TabView(selection: $selectedTab) {
				
				ForEach (0 ... selectedURLs.count - 1, id:\.self) { url in
					
					let parseGPX = parseGPXXML()
					let parseSuccess = parseGPX.parseURL(gpxURL: selectedURLs[url])
					if parseSuccess {
						ForEach (0 ... parseGPX.allTracks.count - 1, id:\.self) { track in
							let header = parseGPX.allTracks[track].header
							let tagValue = Int(url*10 + track)
							
							//let x: String = String(String(url) + ", " 	+ String(track) + ", ") //+ String(selectedTab))
							//let y = x //+// parseGPX.allTracks[track].print(true)
							Text( parseGPX.allTracks[track].print(true))
								.font(.footnote)
								.tag(tagValue)
								.tabItem { Text("\(tagValue)") //", \(header)")
									.font(.caption)
								}.onAppear {
									print("Text.onAppear - \(tagValue), | \(parseGPX.allTracks[track].header)")
								}.onDisappear {
									print("Text.onDisappear - \(url),\(track), | \(parseGPX.allTracks[track].header)")
								}
						}.onAppear {
							beenParsed.toggle()
							tabcount += 1
							//selectedTab = tabcount
							print("ForEachTrack.onAppear Called : \(url)\n")
							print("---------------------------------------")
						}
						.onDisappear {
							tabcount -= 1
							//selectedTab = tabcount
							print("ForEachTrack.onDisappear Called : \(url)")
						}
					} else {
						Text("Parse of \(selectedURLs[url].absoluteURL) failed")
					}
					
					
					//tabcount += 1
					// this is where I will put the actual parse
				}.onAppear {
					print("ForeEachURL.onAppear called : selectedTab - \(selectedTab)")
				}.onDisappear {
					print("ForeEachURL.onDisappear called : selectedTab - \(selectedTab)")
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

