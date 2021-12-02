//
//  NatchParseView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 3/7/21.
//

import SwiftUI


struct GetDateView: View {
	@Binding var startDate : Date
	@Binding var endDate: Date
	
	var body: some View {
		Form  {
			VStack (alignment: .leading) {
				HStack  {
					Text("Start Date")
						.frame(width: 100)
					DatePicker(	"",
								selection: $startDate,
								displayedComponents: [.date])
				}
				HStack  {
					Text("End Date")
						.frame(width: 100)
					DatePicker("",
							selection: $endDate,
							displayedComponents: [.date])
				}
			}
		}
	}
}


struct BatchParseView: View {
	
	@EnvironmentObject var userData: UserData
	@EnvironmentObject var parseGPX :  parseController
	//@EnvironmentObject var bpFiles : BPFiles
	@State private var bpFiles =  BPFiles()
	@State private var startDate = Date()
	@State private var endDate = Date()
	//@State private var xmlFiles = [ReturnStruct]()
	//@State private var xmlFilesAvailable : Bool = false
	@State private var beenParsed : Bool = false
	@State private var insertInDb : Bool = false
	@Binding var stateFlag : FlagStates?
	@State private var bparseCancelled : Bool = false
	
	
	
	
	
	func parseAndInsertParseList(  insert: Bool) -> Bool {
		
		guard bpFiles.xmlFilesAvailable else {
			return false
		}
		
		
		_ = disableScreenSleep()					// When the screen sleeps the parse stops.  Since parsing can take quite awhile,
																	//	disable sleeping until the parse is complete
		for fileIndex in (0 ..< bpFiles.xmlFiles.endIndex) {
				//print("pAIPL: launch parse \(bpFiles.xmlFiles[fileIndex].url)")
			if bpFiles.xmlFiles[fileIndex].parseThis {
			
				let parseGPX = parseController()
				
				DispatchQueue.main.async {
					bpFiles.xmlFiles[fileIndex].parseInProgress = .inProgress
				}
				let parseSuccess = parseGPX.parseSingleFile(bpFiles.xmlFiles[fileIndex].url)
				if parseSuccess {
					
					for track in parseGPX.parsedTracks {
						bpFiles.xmlFiles[fileIndex].numTrkpts.append(track.trackSummary.numberOfDatapoints)
						if insert {
							
							print("inserting adventure into Db")
							let trackDb =   sqlHikingData
							
							if let trackIndex = parseGPX.parsedTracks.firstIndex(of: track) {
								let inserteddbRowNumbers = trackDb.sqlInsertToAllTables(track: track)
								parseGPX.parsedTracks[trackIndex].trkUniqueID = inserteddbRowNumbers.trackdbRow
								bpFiles.xmlFiles[fileIndex].trackdbRow.append(inserteddbRowNumbers.trackdbRow)
								bpFiles.xmlFiles[fileIndex].advdbRow.append(inserteddbRowNumbers.advdbRow)
								userData.append(item: parseGPX.parsedTracks[trackIndex])
								
							} else {
								fatalError("dbInsert in batchParse: \(track.header) not found in parseGPX.parsedTracks")
							}
							//print("GPX file: \(track.header) - inserted @ row: \(trackRow), trkPts @ row: \(trkptRow)")
						} else {
							bpFiles.xmlFiles[fileIndex].trackdbRow.append(-1)
							bpFiles.xmlFiles[fileIndex].advdbRow.append(-1)
						}

					}
				}
				DispatchQueue.main.async {
					bpFiles.xmlFiles[fileIndex].numTracks = parseGPX.parsedTracks.count
					bpFiles.xmlFiles[fileIndex].parseInProgress = .done
						//print("pAIPL: \(bpFiles.xmlFiles[fileIndex].url.lastPathComponent).color = \(bpFiles.xmlFiles[fileIndex].color)")
				}
			}
		}
		_ = enableScreenSleep()					// Since the parse is complete, re-enable the screen sleep function
		return true
	}
	
	func removeTime(date: Date) -> Date {
		let calendar = Calendar.current
		let dateComponents = Calendar.current.dateComponents([.year,.month,.day], from: date)
		return calendar.date(from: dateComponents)!
	}
	
	func getFilesToParse(startDate: Date, endDate: Date) -> [ReturnStruct]
	{
		
		var returnItem : ReturnStruct = ReturnStruct(url:URL(string:"blah")!, parseThis: true, creationDate: Date(), parseInProgress: .notStarted,
									  numTrkpts: [0], trackdbRow: [0], advdbRow: [0])
		var returnString = [ReturnStruct]()
		let fm = FileManager.default
		let path = "/users/rlmankin/documents/hiking/hiking tracks/"
		do {
			let items = try fm.contentsOfDirectory(atPath: path)
			for item in items {
				let itemURL = URL(fileURLWithPath: (path  + item))
				if itemURL.pathExtension.uppercased() == "GPX" {
					let itemAttributes = try fm.attributesOfItem(atPath: itemURL.path)
					let itemCreationDate = itemAttributes[.creationDate] as! Date
					//print("\(itemURL.lastPathComponent): \(itemCreationDate)\n")
					let itemDay = removeTime(date: itemCreationDate)
					let startDay = removeTime(date: startDate)
					let endDay = removeTime(date: endDate)
					let dateRange = startDay ... endDay
					
					if dateRange.contains(itemDay) {
						returnItem.url = itemURL
						returnItem.creationDate = itemCreationDate
						returnItem.parseInProgress = .notStarted
						returnString.append(returnItem)
					}
				}
			}
		} catch {
			print("BatchParseView: getFile: contentsOfDirectory | attributesOfItem has failed")
		}
		returnString.sort(by: {$0.creationDate > $1.creationDate})
		return returnString
	}
	
    var body: some View {
		
			//print("batchparseview body: avail: \(xmlFilesAvailable)\n \(bpFiles.xmlFiles.map {$0.color})")
	
		//return  Group {
			if !bpFiles.xmlFilesAvailable  || bparseCancelled{	// there are no files  or previous batchParse has been cancelled.
				// create the batch parse input form
				Form  {
					VStack (alignment: .leading) {
						HStack  {
							DatePicker(	"Start Date",
										selection: $startDate,
										displayedComponents: [.date])
								.datePickerStyle(DefaultDatePickerStyle())
						
							
							DatePicker("End Date",
									selection: $endDate,
									displayedComponents: [.date])
								.datePickerStyle(DefaultDatePickerStyle())
						}
						
						HStack {
								// toggle for whether to insert into the database or not
							Toggle(isOn: $insertInDb, label: {
								Text("Insert into Hiking Db?")
							})
							Spacer()
								// button to allow to cancel out of this, BEFORE, finding files.  This will go back to the statistics view
							Button( action: {
									bparseCancelled = false
									bpFiles.xmlFiles = getFilesToParse(startDate: startDate, endDate: endDate)
									   //xmlFilesAvailable = !bpFiles.xmlFiles.isEmpty
							}) 	{Text("Find files").frame( alignment: .center)
								}
							Button( action: {
								stateFlag = FlagStates.empty
							}) {Text("Cancel")}
							Spacer()
						}
					}
				}
					
					
			} else {
					// there are files in the bpFiles array
				HStack {
						// button to cancel out of the parsing view when files are selected
					Button( action: {
								stateFlag = (beenParsed == true ? FlagStates.empty : FlagStates.batchParse)
								bparseCancelled = true
							}
						)
					{ Text("\(beenParsed == true ? "Done" : "Cancel")")}
					Spacer()
						// button to parse the files identified.
					Button( action: {
									// create a background queue
								let parseQueue = DispatchQueue(label: "batchParseQueue", attributes: .concurrent)
									// parse and insert the results into the database for each file in bpFiles
								parseQueue.async {
									parseAndInsertParseList(insert: insertInDb)
									beenParsed = true
								}
							}
					  	)
						{Text("parse files?").frame(alignment: .center) }.disabled(beenParsed)
					 Spacer()
					 Toggle(isOn: $insertInDb, label: {
						Text("Insert?")
					}
					 ).disabled(beenParsed)
					Spacer()
				}
				if bpFiles.xmlFilesAvailable {
					BPListView(bpFiles: $bpFiles)
						
				}
					
					
					
			}
			
			
		//}
    }
}

struct BatchParseView_Previews: PreviewProvider {
    static var previews: some View {
		BatchParseView(stateFlag: .constant(FlagStates.batchParse))
    }
}
