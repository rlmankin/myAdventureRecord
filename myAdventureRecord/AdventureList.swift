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



struct CommandButtonsView: View {
	@EnvironmentObject  var userData: UserData
	@EnvironmentObject var parseGPX: parseController				// contains all tracks from a set of requested URLs
	
	@Binding  var showDBTable : Bool
	@Binding  var batchParse : Bool
	@Binding  var stateFlag : FlagStates?
	@Binding  var parseFileRequested : Bool
	@Binding  var filterBy : Adventure.HikeCategory
	
	
	var body: some View {
		
		timeStampLog(message: "-> adventureList/CommandButtons")
		return
			HStack {
				//  The Command Buttons must be enclosed in a List to eliminate the "Unable to present, File a bug" warning in Xcode 12.5.1.
				//		I don't know why this works, but is recommended as a fix in https://stackoverflow.com/questions/67276205/swiftui-navigationlink-for-ios-14-5-not-working
				List {
				
				//	empty *****
				//	this will display nothing in the detailview.  Trying to use when navigating back to the 'default' view from varous button pushes
				//		(e.g. cancel for parses, list for dbTable)
				NavigationLink(
					destination: EmptyView(),
					tag: FlagStates.empty,
					selection: self.$stateFlag,
					label:  {Text("").toolbar {}
							}
				)
				
					
				//	parse *****
				//	if the parse button is selected, show the file importer dialog box to allow the user to selected .gpx files for parsing
				NavigationLink(
					destination: GPXParsingView(),
					tag: FlagStates.parseFile,
					selection: self.$stateFlag,
					label: {Text("").toolbar {
						/*Button("Parse") {
							showDBTable = false
							parseFileRequested.toggle()
						}.buttonStyle(NavButtonStyle())*/
					}})
					.navigationTitle("Parse")
					// when a parse has been requested, parseFileRequested will be true and the fileImporter dialog will be displayed
					.fileImporter(isPresented: $parseFileRequested,
									allowedContentTypes: [.xml],					//	allow any .xml type.  There is exposure that a non-GPX xml file will be selected
									allowsMultipleSelection: true)					//	allow multitple files to be selected, but not directoies
						{result in
							do {
									//	get the URLs of all the files requested
								let selectedURLs = try result.get()
									//	if no files are selected or "cancel" pressed then close the dialog and reeturn to the previous view.  This is accomlished
									//		by setting stateflag to either empty or parsefile
								stateFlag = (selectedURLs.isEmpty ? .empty : .parseFile)
								if stateFlag == FlagStates.parseFile {
								//parseFile = !selectedURLs.isEmpty
								//if !parseFile {
								//	stateFlag = .empty
								//} else {
									let parseFilesSuccess = parseGPX.parseGpxFileList(selectedURLs)	// parse all the selected URLs in background
										parseFileRequested.toggle()						//	turn off parseFileRequested to indicate we have received a set of URLs
								}
						   } catch {
							   print("AdventureList: parseFile: fileImporter catch occured from get.")
						   }
						}
				
				// dBTable *****
				NavigationLink(
					destination: HikingDBView(),
					tag: FlagStates.showDBTable,
					selection: self.$stateFlag,
					label: {Text("").toolbar {
					}})
					.navigationTitle("dBView")
				
				//batchParse *****
				NavigationLink(
					destination: BatchParseView(stateFlag: $stateFlag),
					tag: FlagStates.batchParse,
					selection: self.$stateFlag,
					label: {Text("").toolbar {
						/*Button("batchparse)") {
							stateFlag = .batchParse
							//batchParse.toggle()
							showDBTable = false
							if !showDBTable {
								//userData.reload(tracksOnly: true)
							}
						}.buttonStyle(NavButtonStyle())*/
					}})
					.navigationTitle("batchParse")
				
			} //List
				
			Text("")
				.toolbar {
					ToolbarItem() {
						Menu("Commands") {
							Button("Parse") {
								showDBTable = false
								stateFlag = .parseFile
								parseFileRequested.toggle()
							}
							Button("\(showDBTable == true ? "List" : "dbTable")") {
								stateFlag = .showDBTable
								showDBTable.toggle()
								if !showDBTable {
									stateFlag = .empty
									userData.reload(tracksOnly: true)		// reload userData to reflect changes as a result of deleting adventures from the database table
								}
							}
							Button("batchparse") {
								stateFlag = .batchParse
								//batchParse.toggle()
								showDBTable = false
								if !showDBTable {
									//userData.reload(tracksOnly: true)
								}
							}
						}
					}
					ToolbarItem() {
						Menu("Filter") {
							Menu("Category") {
								Button("all", action: { filterBy = .all})
								Button("Hike", action: {filterBy = .hike})
								Button("Off Road", action: {filterBy = .orv})
								Button("Scenic Drive", action: {filterBy = .scenicDrive})
								Button("Snowshoe", action: {filterBy = .snowshoe})
								Button("Not Categorized", action: {filterBy = .none})
							}
							Button("Area", action: {})
							Button("Title", action: {})
						}
					}
					
				}
				
			}	//HStack
	}
}

struct AdventureList: View {
	
	@EnvironmentObject var userData: UserData
	@EnvironmentObject var parseGPX: parseController				// contains all tracks from a set of requested URLs
	
	@State private var selectedURLs : [URL] = []
	// the following flags should probably be transitioned to enums to make view management more readable and clear
	
	@State private var stateFlag : FlagStates? = .empty
	@State private var showDBTable = false							// flag to display the SQL database table (true), or not (false)
	
	@State private var parseFile = false							// flag to show if requested to parse a GPX file (true)
	@State private var batchParse = false
	@State private var parseFileRequested = false
	@State private var refreshList = false
	
	@State private var filterBy :  Adventure.HikeCategory = .all
	var filteredAdventures : [Adventure] {
		if filterBy == .all {
			return userData.adventures
		} else {
			return userData.adventures.filter {$0.hikeCategory == filterBy}
		}
	}
	func printStateVars() {
		print("stateFlag: \(stateFlag)", terminator: " ")
		print("showDBtable: \(showDBTable)", terminator: " ")
		print("parseFile: \(parseFile)", terminator: " ")
		print("batchParse: \(batchParse)", terminator: " ")
		print("parseFileRequested: \(parseFileRequested)", terminator: " ")
		print("refreshList: \(refreshList)")
	}
	
	
	
	
    var body: some View {
		
		
		timeStampLog(message: "-> adventureList body")
			//printStateVars()
		
		return
			Group {
			
				
				
				// The list of Adventures
				
				NavigationView {
				// the List provide the rows in the navigation view (left pane) by walking through all entries in the userData structure
				// HStack for the buttons at the top.  Seems to be required to get
				//	the buttons to correctdly call the detail view
				
					List  {
						
						
						CommandButtonsView(showDBTable: $showDBTable, batchParse: $batchParse, stateFlag: $stateFlag, parseFileRequested: $parseFileRequested, filterBy: $filterBy)
						
						
						
						//	The List of Adventure *****
						//	in the loop, create a navigation link for each entry.  if the adventure is selected, the display the detail in the
						//	detail view (right pane)
						ForEach(filteredAdventures/*userData.adventures*/) { adventure in
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
		}
	}
}

struct AdventureList_Previews: PreviewProvider {
    static var previews: some View {
		AdventureList()
			.environmentObject(UserData())
    }
}
