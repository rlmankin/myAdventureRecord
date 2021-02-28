//
//  AdventureList.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/10/20.
//

import SwiftUI

struct AdventureList: View {
	@EnvironmentObject  var userData: UserData
	@EnvironmentObject var parseGPX: parseController				// contains all tracks from a set of requested URLs
	@State private var selectedAdventure: Adventure?
	@State private var showDBTable = false							// flag to show the SQL database table (true), or not (false)
	@State private var showingParseDetail : Adventure? = nil		// will contain the adventure data from a parse
	@State private var parseFile = false							// flag to show if requested to parse a GPX file (true)
	@State private var firstParse = true
	@State private var parseFileRequested = false
	
	//@State private var selectedURL : URL = URL(string: "nofileselected")!
	//@State private var tabcount: Int = 1
	//@State private var selectedTab : Int = 1
	
	
	
	@State  var selectedURLs : [URL] = []
	
	
	
	
    var body: some View {
		
		Group {
			HStack {
				Text(String(showDBTable))
				Text(String(parseFile))
				Text(String(userData.adventures.count))
				Text(String(firstParse))
				if showingParseDetail == nil {
					Text("nil")
				} else {
					Text(showingParseDetail!.name)
				}
				
	
			}
		
		
			switch (showDBTable, parseFile) {
				case (false, false) :
					//if !parseFileRequested {
						NavigationView {
							List  {
								ForEach(userData.adventures) { adventure in
									NavigationLink(destination: AdventureDetail(adventure: adventure)) {
										AdventureRow(adventure: adventure)
									}.tag(adventure)				}
							}
							.toolbar {
								ToolbarItemGroup (placement: .automatic) {
									Button("\(showDBTable == true ? "List" : "dbTable")") {
										showDBTable.toggle()
									}
									
									Button("Parse") {
										parseFileRequested.toggle()
										firstParse = true
										
									}
								}
							 }
						}.fileImporter(isPresented: $parseFileRequested,
									   allowedContentTypes: [.xml],
											 allowsMultipleSelection: true)
								 {result in
									do {
										 let fileURLs = try result.get()
										 selectedURLs = fileURLs
										 parseFile = !selectedURLs.isEmpty
										 print(selectedURLs)
										 let parseFilesSuccess = parseGPX.parseGpxFileList(selectedURLs)
										 firstParse = false
										 parseFileRequested.toggle()
								 } catch {
									 print("Fail")
								 }
					}
				case (true, false) :
					
					HikingDBView().toolbar {
						   ToolbarItem {
							   
							   Button("\(showDBTable == true ? "<dBBack" : "dbTable")") {
								   showDBTable.toggle()
							   }
						   
						   }
					}.navigationTitle("tableView")
				case (false, true) :
					if firstParse {
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
							
					} else {
						if showingParseDetail != nil {
							AdventureDetail(adventure: showingParseDetail!).toolbar {
								ToolbarItem {
									Button("<Return") {
										showingParseDetail = nil
										parseFile = false
										firstParse = false
										parseFileRequested = false
									}
								}
							}.navigationTitle("detailView")
						} else {
							GPXParsingView(showingParseDetail: $showingParseDetail, firstParse: $firstParse, parseFile: $parseFile)
								.toolbar {
									ToolbarItem (placement: .navigation) {
										HStack {
											Button( "<parseBack") {
												parseFile = false
												firstParse = false
												parseFileRequested = false
											}
										}
									
									}
								}
								.navigationTitle("parsingView")
						}
			
						
					}
				
				case (true, true) : Text("Error (true,true)")
			
			
			}
		
		}
		
	}
}

struct AdventureList_Previews: PreviewProvider {
    static var previews: some View {
		AdventureList()
			.environmentObject(UserData())
    }
}
