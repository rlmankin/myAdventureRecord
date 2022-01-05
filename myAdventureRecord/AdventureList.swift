//
//  AdventureList.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/10/20.
//

import SwiftUI

enum FlagStates {
	case showFilterView
	case showDBTable
	case parseFile
	case batchParse
	case refreshList
	case empty
}

struct FilterRange {
	var filterRange : ClosedRange<Double> = 0...0
	var baseRange : ClosedRange<Double> = 0...0
}
struct FilterVars {
	
	var filterByCategory : [Adventure.HikeCategory] = [.hike, .walkabout, .orv, .scenicDrive, .snowshoe, .none]
	var filterByDifficulty : [Color] = difficultyCases
	var searchArea : String = nullString
	var searchTitle : String = nullString
	/*let startDate: Date?  = { let df = DateFormatter()
							 df.dateFormat = "MM/dd/yyyy"
							 if let theDate = df.date(from: "01/01/2013") {
								 return theDate
							 } else {
								 return Date()
							 }
						  }()*/
	var searchDateRange : ClosedRange<Date> = { let df = DateFormatter()
												 df.dateFormat = "MM/dd/yyyy"
											     if let theDate = df.date(from: "01/01/2013") {
												   return theDate
											     } else {
												   return Date()
											     }
											  }() ... Date()
	var searchEndDate = Date()
	var searchLength = FilterRange()
	var searchPace = FilterRange()
	var searchAscent = FilterRange()
	var searchDescent = FilterRange()
	var searchMaxElevation = FilterRange()
	
}







struct AdventureList: View {
	
	@EnvironmentObject var userData: UserData
	@EnvironmentObject var parseGPX: parseController				// contains all tracks from a set of requested URLs
	
	@State private var selectedURLs : [URL] = []
	@State private var stateFlag : FlagStates? = .empty
	@State private var showDBTable = false							// flag to display the SQL database table (true), or not (false)
	@State private var parseFile = false							// flag to show if requested to parse a GPX file (true)
	@State private var batchParse = false
	@State private var parseFileRequested = false
	@State private var refreshList = false
		// Filtering State variables
	@State private var filtervars = FilterVars()
	@State private var showfilterView : Bool = false
	
	func filterAdventures(adventures: [Adventure]) -> [Adventure] {
		timeStampLog(message: "->filterAdventures.count \(adventures.count)")
		var filteredAdventures = adventures
		let categoryIntersection = Array(Set(filteredAdventures.map({$0.hikeCategory})).intersection(filtervars.filterByCategory))
		filteredAdventures =  filteredAdventures.filter { categoryIntersection.contains( $0.hikeCategory)}
		
		let difficultyIntersection = Array(Set(filteredAdventures.map({$0.difficulty.color})).intersection(filtervars.filterByDifficulty))
		filteredAdventures = filteredAdventures.filter { difficultyIntersection.contains( $0.difficulty.color)}
		filteredAdventures = filteredAdventures.filter { $0.area.lowercased().contains(filtervars.searchArea.lowercased()) }
		filteredAdventures = filteredAdventures.filter {$0.name.lowercased().contains(filtervars.searchTitle.lowercased()) }
//******************  making filterAdventures more swifty as part of adding baseRange to slider range values
		filteredAdventures = filteredAdventures.filter {filtervars.searchDateRange.contains( $0.trackData.trackSummary.startTime! >= filtervars.searchStartDate  &&
													$0.trackData.trackSummary.endTime! <= filtervars.searchEndDate }
		
		if filtervars.searchLength.filterRange.upperBound > 0 {
			filteredAdventures = filteredAdventures.filter {filtervars.searchLength.filterRange.contains($0.distance/metersperMile)}
			}
		}
		
		if filtervars.searchPace.upper > 0 {
			filteredAdventures = filteredAdventures.filter {$0.trackData.trackSummary.avgSpeed/metersperMile*secondsperHour <= filtervars.searchPace.upper &&
				$0.trackData.trackSummary.avgSpeed/metersperMile*secondsperHour >= filtervars.searchPace.lower
			}
		}
		if filtervars.searchAscent.upper > 0 {
			filteredAdventures = filteredAdventures.filter {$0.trackData.trackSummary.totalAscent*feetperMeter <= filtervars.searchAscent.upper &&
				$0.trackData.trackSummary.totalAscent*feetperMeter >= filtervars.searchAscent.lower
			}
		}
		if filtervars.searchDescent.lower < 0 {
			filteredAdventures = filteredAdventures.filter {$0.trackData.trackSummary.totalDescent*feetperMeter <= filtervars.searchDescent.upper &&
				$0.trackData.trackSummary.totalDescent*feetperMeter >= filtervars.searchDescent.lower
			}
		}
		if filtervars.searchMaxElevation.upper > 0 {
			filteredAdventures = filteredAdventures.filter {$0.trackData.trackSummary.elevationStats.max.elevation * feetperMeter <= filtervars.searchMaxElevation.upper &&
				$0.trackData.trackSummary.elevationStats.max.elevation * feetperMeter >= filtervars.searchMaxElevation.lower
			}
		}
		return filteredAdventures
	}
	
	
	
	
    var body: some View {
		
		
		timeStampLog(message: "-> adventureList body, \(self.stateFlag), \(showDBTable)")
			//printStateVars()
		var filteredAdventures : [Adventure] {
			timeStampLog(message: "->var filteredAdventures")
			return filterAdventures(adventures: userData.adventures)
			
		}
		return
			// The list of Adventures
			
			NavigationView {
			// the List provide the rows in the navigation view (left pane) by walking through all entries in the userData structure
			// HStack for the buttons at the top.  Seems to be required to get
			//	the buttons to correctdly call the detail view
				List  {
					NavigationLink(
						destination: SplashView(filteredAdventures: filteredAdventures),
						tag: FlagStates.empty,
						selection: self.$stateFlag,
						label: { Text("empty").toolbar {}}
					).hidden()
					//CommandButtonsView(showDBTable: $showDBTable, batchParse: $batchParse, stateFlag: $stateFlag, parseFileRequested: $parseFileRequested, filtervars: $filtervars , filteredAdventures: filteredAdventures)
					
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
				.background(
					HStack {
						
							
						// dBTable *****
						NavigationLink(
							destination: HikingDBView(stateFlag: self.$stateFlag),
							tag: FlagStates.showDBTable,
							selection: self.$stateFlag,
							label: 	{Text("dbTable").toolbar {}
									}
						).navigationTitle("dBView")
						
						//batchParse *****
						NavigationLink(
							destination: BatchParseView(stateFlag: $stateFlag),
							tag: FlagStates.batchParse,
							selection: self.$stateFlag,
							label: 	{Text("bParse").toolbar {}
									}
						).navigationTitle("batchParse")
							
						//filterview *****
						NavigationLink(
							destination: FilterView(filtervars: $filtervars, stateFlag: $stateFlag, noFilteredAdventures: filteredAdventures.isEmpty),
							tag: FlagStates.showFilterView,
							selection: self.$stateFlag,
							label: 	{Text("filterview").toolbar {}
									}
						).navigationTitle("filterview")
						
						//	parse *****
						//	if the parse button is selected, show the file importer dialog box to allow the user to selected .gpx files for parsing
						NavigationLink(
							destination: GPXParsingView(),
							tag: FlagStates.parseFile,
							selection: self.$stateFlag,
							label: 	{Text("parse").toolbar {}
									}
						).navigationTitle("Parse")
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
					}
				)
				.toolbar {
				// Command pulldown menu.  Used for specific operations (e.g. parse a file, list the database, batchparse many files)
					ToolbarItem() {
						Menu("Commands") {
							Button("Splash") {
								self.stateFlag = .empty
								showDBTable = false
								
							}
							Button("Filter") {
									// Clear any previous filter criteria before calling FilterView
								self.filtervars.filterByCategory.removeAll()
								self.filtervars.filterByDifficulty.removeAll()
									// Show the FilterView
								self.stateFlag = .showFilterView
								showDBTable = false
								
							}
							Button("Parse") {
								showDBTable = false
								self.stateFlag = .parseFile
								parseFileRequested.toggle()
							}
							Button("\(showDBTable == true ? "List" : "dbTable")") {
								stateFlag = .showDBTable
								showDBTable.toggle()
								if !showDBTable {
									self.stateFlag = .empty
									userData.reload(tracksOnly: true)		// reload userData to reflect changes as a result of deleting adventures from the database table
								}
							}
							Button("batchparse") {
								self.stateFlag = .batchParse
								showDBTable = false
								if !showDBTable {
									//userData.reload(tracksOnly: true)
								}
							}
						}
						
					}
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
