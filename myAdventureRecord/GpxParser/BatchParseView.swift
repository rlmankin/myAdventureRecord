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
	//@Binding var xmlFilesAvailable: Bool
	//@EnvironmentObject var bpFiles: BPFiles
	
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
	
	@EnvironmentObject var parseGPX :  parseController
	@EnvironmentObject var bpFiles : BPFiles
	@State private var startDate = Date()
	@State private var endDate = Date()
	//@State private var xmlFiles = [ReturnStruct]()
	@State private var xmlFilesAvailable : Bool = false
	@State private var beenParsed : Bool = false
	@State private var insertInDb : Bool = false
	
	
	
	
	
	func parseAndInsertParseList(  insert: Bool) -> Bool {
		
		
		for fileIndex in (0 ... bpFiles.xmlFiles.count - 1) {
			print("pAIPL: launch parse \(bpFiles.xmlFiles[fileIndex].url)")
			let parseGPX = parseController()
			
			DispatchQueue.main.async {
				bpFiles.xmlFiles[fileIndex].parseInProgress = .inProgress
				print("pAIPL: \(bpFiles.xmlFiles[fileIndex].url.lastPathComponent).color = \(bpFiles.xmlFiles[fileIndex].color)")
			}
			let  parseSuccess = parseGPX.parseSingleFile(bpFiles.xmlFiles[fileIndex].url)
			if parseSuccess {
				
				for track in parseGPX.parsedTracks {
					bpFiles.xmlFiles[fileIndex].numTrkpts.append(track.trackSummary.numberOfDatapoints)
					if insert {
						//track.print()
						let trackDb = SqlHikingDatabase()		//	open and connect to the hinkingdbTable of the SQL hiking database
						let trkptDb = SqlTrkptsDatabase()		//	connect to the trkptsTable of the SQL hiking database
						let trackRow = trackDb.sqlInsertDbRow(track)
						let trkptRow = trkptDb.sqlInsertTrkptList(trackRow, track.trkptsList)
						bpFiles.xmlFiles[fileIndex].trackRow.append(trkptRow)
						
						//print("GPX file: \(track.header) - inserted @ row: \(trackRow), trkPts @ row: \(trkptRow)")
						}

				}
			}
			DispatchQueue.main.async {
				bpFiles.xmlFiles[fileIndex].numTracks = parseGPX.parsedTracks.count
				bpFiles.xmlFiles[fileIndex].parseInProgress = .done
				
				
				print("pAIPL: \(bpFiles.xmlFiles[fileIndex].url.lastPathComponent).color = \(bpFiles.xmlFiles[fileIndex].color)")
			}
		}
		
		return true
	}
	
	func getFile(startDate: Date, endDate: Date) -> [ReturnStruct]
	{
		
		var returnItem = ReturnStruct(url:URL(string:"blah")!, creationDate: Date(), parseInProgress: .notStarted,
									  numTrkpts: [0], trackRow: [0], trkptRow: [0])
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
					if (itemCreationDate <= endDate) && (itemCreationDate >= startDate) {
						returnItem.url = itemURL
						returnItem.creationDate = itemCreationDate
						returnItem.parseInProgress = .notStarted
						returnString.append(returnItem)
					}
				}
				
			}
		} catch {
			print("Fail")
		}
		returnString.sort(by: {$0.creationDate < $1.creationDate})
		return returnString
	}
	
    var body: some View {
		
		print("batchparseview body: avail: \(xmlFilesAvailable)\n \(bpFiles.xmlFiles.map {$0.color})")
	
		return  Group {
			if !xmlFilesAvailable {
				Form  {
					VStack (alignment: .leading) {
						HStack  {
							DatePicker(	"Start Date",
										selection: $startDate,
										displayedComponents: [.date])
								.datePickerStyle(GraphicalDatePickerStyle())
						
							
							DatePicker("End Date",
									selection: $endDate,
									displayedComponents: [.date])
								.datePickerStyle(GraphicalDatePickerStyle())
						}
						
						HStack {
							Toggle(isOn: $insertInDb, label: {
								Text("Insert into Hiking Db?")
							})
							Spacer()
							Button( action: {
									bpFiles.xmlFiles = getFile(startDate: startDate, endDate: endDate)
									   xmlFilesAvailable = !bpFiles.xmlFiles.isEmpty
							}) 	{Text("find files").frame( alignment: .center)
								}
							Spacer()
						}
					}
				}
					
					
			} else {
				
				HStack {
					Spacer()
					Button( action: {
							let parseQueue = DispatchQueue(label: "batchParseQueue", attributes: .concurrent)
							print("Body: bpFiles.xmlFiles @ button dispatch: \(bpFiles.xmlFiles)")
							parseQueue.async {
								parseAndInsertParseList(insert: false)
								beenParsed = true
							}
					})
					{	Text("parse files?").frame(alignment: .center) }.disabled(beenParsed)
					Spacer()
					Toggle(isOn: $insertInDb, label: {
						Text("Insert?")
					}).disabled(beenParsed)
					Spacer()
				}
				if !bpFiles.xmlFiles.isEmpty {
					BPListView()
				}
					
					
					
			}
			
			
		}
    }
}

struct BatchParseView_Previews: PreviewProvider {
    static var previews: some View {
        BatchParseView()
			.environmentObject(BPFiles())
    }
}
