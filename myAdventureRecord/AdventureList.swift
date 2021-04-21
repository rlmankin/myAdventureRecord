//
//  AdventureList.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/10/20.
//

import SwiftUI

struct BPReturnButton: View {
	var body: some View {
		HStack {
			Image( systemName: "chevron-left")
			Text( "bpreturn ")	//\(String(batchParse))")
			}
	}
}

struct AdventureList: View {
	
	@EnvironmentObject  var userData: UserData
	@EnvironmentObject var parseGPX: parseController				// contains all tracks from a set of requested URLs
	
	@State private var showDBTable = false							// flag to show the SQL database table (true), or not (false)
	//@State private var showingParseDetail : Adventure? = nil		// will contain the adventure data from a parse
	@State private var parseFile = false							// flag to show if requested to parse a GPX file (true)
	@State private var batchParse = false
	@State private var parseFileRequested = false
	@State private var selectedURLs : [URL] = []
	
    var body: some View {
		
		timeStampLog(message: "-> adventureList body")
		
		return NavigationView {
			// the List provide the rows in the navigation view (left pane) by walking through all entries in the userData structure
			List  {
				// HStack for the buttons at the top.  Seems to be required to get
				//	the buttons to correctdly call the detail view
				HStack {
					//	if the dbTable button is selected, show the database table in the detail view (right pane), but maintain the navigation view list (left pane)
					NavigationLink(destination: HikingDBView()
									.navigationTitle(Text("dbTableView").italic()),
									isActive: $showDBTable)							// isActive: true displays the table, isActive:false make the view disappear
					{ Text("").toolbar {	// tried this with EmptyView but the menu button is not shown
						Button("\(showDBTable == true ? "List" : "dbTable")") {
								userData.reload(tracksOnly: true)
								showDBTable.toggle()
								print("Button: showDBTable -\(showDBTable)")
							}.buttonStyle(NavButtonStyle())
						}.tag("dbTable")											// tag this link with the string "dbTable"
					
					}
						
						
					//	if the parse button is selected, show the file importer dialog box to allow the user to selected .gpx files for parsing
					NavigationLink(destination: GPXParsingView()	// display the parsing view (showDetail if requested)
									.navigationTitle("parsingView"),
									isActive: $parseFile)
					{ Text("").toolbar {
						Button("Parse") {
								parseFileRequested.toggle()
								//batchParse = false
							}.buttonStyle(NavButtonStyle())
						}.tag("parse")
					}
					
					NavigationLink(destination: BatchParseView(batchParse: $batchParse)	// display the parsing view (showDetail if requested)
									.navigationTitle("batchParseView"),
									 isActive: $batchParse)
					{ Text("").toolbar {
						Button("batchParse") {
							print("before: \(batchParse)")
							batchParse.toggle()
							print("after: \(batchParse)")
							}.buttonStyle(NavButtonStyle())
						}.tag("batchParse")
					}
				}
				//	in the loop, create a navigation link for each entry.  if the adventure is selected, the display the detail in the
				//	detail view (right pane)
				ForEach(userData.adventures) { adventure in
					NavigationLink(destination: AdventureDetail(passedAdventure: adventure, beenInserted: true)) {
						AdventureRow(adventure: adventure)
					}.tag(adventure)
				}
				
				
			}.frame(minWidth:400, maxWidth: 600)				// .frame here sets the width of the left hand pane of the navigationView
											//		it is important that .frame attaches to the List because the List
											//		is the view in the left pane
		
		}
		// when a parse has been requested, parseFileRequested will be true and the fileImporter dialog will be displayed
		.fileImporter(isPresented: $parseFileRequested,
					   allowedContentTypes: [.xml],							//	allow any .xml type.  There is exposure that a non-GPX xml file will be selected
							 allowsMultipleSelection: true)					//	allow mulitple files to be selected, but not directoies
				 {result in
					do {
							let selectedURLs = try result.get()				//	get the URLs of all the files requested
							parseFile = !selectedURLs.isEmpty				//	if no files are selected or "cancel" pressed then close the dialog and return to the
																			//		previous view
							let parseFilesSuccess = parseGPX.parseGpxFileList(selectedURLs)	// parse all the selected URLs in background
							parseFileRequested.toggle()						//	turn off parseFileRequested to indicate we have received a set of URLs
					   } catch {
						   print("Fail")
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
