//
//  AdventureList.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/10/20.
//

import SwiftUI

enum FlagStates {
	case showDBTable
	case parseFile
	case batchParse
	case refreshList
	case empty
}

struct BPReturnButton: View {
	var body: some View {
		HStack {
			Image( systemName: "chevron-left")
			Text( "bpreturn ")	//\(String(batchParse))")
			}
	}
}

struct CommandButtons: View {
	@EnvironmentObject  var userData: UserData
	@Binding  var showDBTable : Bool
	@Binding  var batchParse : Bool
	@Binding  var stateFlag : FlagStates?
	@Binding  var parseFileRequested : Bool
	
	
	var body: some View {
		
		timeStampLog(message: "-> adventureList/CommandButtons")
		return
			HStack {
				//  The Command Buttons must be enclosed in a List to eliminate the "Unable to present, File a bug" warning in Xcode 12.5.1.
				//		I don't know why this works, but is recommended as a fix in https://stackoverflow.com/questions/67276205/swiftui-navigationlink-for-ios-14-5-not-working
				List {
				
				
				//	parse *****
				//	if the parse button is selected, show the file importer dialog box to allow the user to selected .gpx files for parsing
				NavigationLink(
					destination: GPXParsingView(),
					tag: FlagStates.parseFile,
					selection: self.$stateFlag,
					label: {Text("").toolbar {
						Button("Parse") {
							stateFlag = .parseFile
							showDBTable = false
							parseFileRequested.toggle()
						}.buttonStyle(NavButtonStyle())
					}})
				
				// dBTable *****
				NavigationLink(
					destination: HikingDBView(),
					tag: FlagStates.showDBTable,
					selection: self.$stateFlag,
					label: {Text("").toolbar {
						Button("\(showDBTable == true ? "List" : "dbTable")") {
							stateFlag = .showDBTable
							showDBTable.toggle()
							if !showDBTable {
								userData.reload(tracksOnly: true)
							}
						}.buttonStyle(NavButtonStyle())
					}})
				
				//batchParse *****
				NavigationLink(
					destination: BatchParseView(batchParse: $batchParse),
					tag: FlagStates.batchParse,
					selection: self.$stateFlag,
					label: {Text("").toolbar {
						Button("batchparse)") {
							stateFlag = .batchParse
							batchParse.toggle()
							showDBTable = false
							if !showDBTable {
								userData.reload(tracksOnly: true)
							}
						}.buttonStyle(NavButtonStyle())
					}})
				} //List
				
			}	//HStack
	}
}

struct AdventureList: View {
	
	@EnvironmentObject  var userData: UserData
	@EnvironmentObject var parseGPX: parseController				// contains all tracks from a set of requested URLs
	
	@State private var selectedURLs : [URL] = []
	// the following flags should probably be transitioned to enums to make view management more readable and clear
	
	@State private var stateFlag : FlagStates? = .empty
	@State private var showDBTable = false							// flag to display the SQL database table (true), or not (false)
	
	@State private var parseFile = false							// flag to show if requested to parse a GPX file (true)
	@State private var batchParse = false
	@State private var parseFileRequested = false
	@State private var refreshList = false
	
	func printStateVars() {
		print("showDBtable: \(showDBTable)", terminator: " ")							// flag to show the SQL database table (true), or not (false)
		print("parseFile: \(parseFile)", terminator: " ")
		print("batchParse: \(batchParse)", terminator: " ")
		print("parseFileRequested: \(parseFileRequested)", terminator: " ")
		print("refreshList: \(refreshList)")
	}
	
	
    var body: some View {
		
		
		timeStampLog(message: "-> adventureList body")
			//printStateVars()
		
		return NavigationView {
			// the List provide the rows in the navigation view (left pane) by walking through all entries in the userData structure
			// HStack for the buttons at the top.  Seems to be required to get
			//	the buttons to correctdly call the detail view
			
			List  {
				
				
				CommandButtons(showDBTable: $showDBTable, batchParse: $batchParse, stateFlag: $stateFlag, parseFileRequested: $parseFileRequested)
				// The list of Adventures
				
				
				
				//	The List of Adventure *****
				//	in the loop, create a navigation link for each entry.  if the adventure is selected, the display the detail in the
				//	detail view (right pane)
				ForEach(userData.adventures) { adventure in
					NavigationLink(
						destination: AdventureDetail(passedAdventure: adventure, beenInserted: true)) {
							AdventureRow(adventure: adventure)
							}
					.tag(adventure)
				}
			
				
				
			}.frame(minWidth:400, maxWidth: 600)				// .frame here sets the width of the left hand pane of the navigationView
											//		it is important that .frame attaches to the List because the List
											//		is the view in the left pane
		
		}
		// when a parse has been requested, parseFileRequested will be true and the fileImporter dialog will be displayed
		.fileImporter(isPresented: $parseFileRequested,
					   	allowedContentTypes: [.xml],					//	allow any .xml type.  There is exposure that a non-GPX xml file will be selected
						allowsMultipleSelection: true)					//	allow mulitple files to be selected, but not directoies
			{result in
				do {
						let selectedURLs = try result.get()				//	get the URLs of all the files requested
						parseFile = !selectedURLs.isEmpty				//	if no files are selected or "cancel" pressed then close the dialog and
																		//		return to the previous view
						let parseFilesSuccess = parseGPX.parseGpxFileList(selectedURLs)	// parse all the selected URLs in background
						parseFileRequested.toggle()						//	turn off parseFileRequested to indicate we have received a set of URLs
				   } catch {
					   print("AdventureList: parseFile: fileImporter catch occured from get.")
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
