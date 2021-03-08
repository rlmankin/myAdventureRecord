//
//  NatchParseView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 3/7/21.
//

import SwiftUI



struct BatchParseView: View {
	@State private var startDate = Date()
	@State private var endDate = Date()
	@State private var xmlFiles = [ReturnStruct]()
	@State private var xmlFilesAvailable : Bool = false
	
	struct ReturnStruct {
		var url: URL
		var creationDate: Date
	}
	
	func getFile(startDate: Date, endDate: Date) -> [ReturnStruct]
	{
		
		var returnItem = ReturnStruct(url:URL(string:"blah")!, creationDate: Date())
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
					print("\(itemURL.lastPathComponent): \(itemCreationDate)\n")
					if (itemCreationDate <= endDate) && (itemCreationDate >= startDate) {
						returnItem.url = itemURL
						returnItem.creationDate = itemCreationDate
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
	
	func parseParseList( fileArray: [URL]) -> Bool {
		
		var parseGPX = parseController()
		let  parseSuccess = parseGPX.parseCommandLineGPX(fileArray)

		if parseSuccess {
			for track in parseGPX.parsedTracks {
				//track.print()
				let trackDb = SqlHikingDatabase()		//	open and connect to the hinkingdbTable of the SQL hiking database
				let trkptDb = SqlTrkptsDatabase()		//	connect to the trkptsTable of the SQL hiking database
				let trackRow = trackDb.sqlInsertDbRow(track)
				let trkptRow = trkptDb.sqlInsertTrkptList(trackRow, track.trkptsList)
				print("GPX file: \(track.header) - inserted @ row: \(trackRow), trkPts @ row: \(trkptRow)")
			}
		}
		
		return parseSuccess
	}
	
	
	
    var body: some View {
		Form  {
			VStack (alignment: .leading) {
				HStack  {
					Text("Start Date")
					DatePicker(	"",
								selection: $startDate,
							  	displayedComponents: [.date])
				}
				HStack  {
					Text("End Date")
					DatePicker("",
							selection: $endDate,
							displayedComponents: [.date])
				}
				
				
			
				if xmlFiles.count != 0 {
					Button( action: {
								xmlFiles = getFile(startDate: startDate, endDate: endDate)
								
								print(xmlFiles)
							})
					{ Text("parse files")}
					List {
					
						ForEach (0...xmlFiles.count-1, id:\.self) { fileIndex in
							HStack (spacing: 3){
								Text("\(xmlFiles[fileIndex].url.lastPathComponent): ")
								Text(xmlFiles[fileIndex].creationDate, style: .date)
							}
						}
					}
				} else {
					Button( action: {
						xmlFiles = getFile(startDate: startDate, endDate: endDate)
								 print(xmlFiles)
					 })
					 { Text("find files")}
				}
				
				
									
			}.padding()
		}
    }
}

struct BatchParseView_Previews: PreviewProvider {
    static var previews: some View {
        BatchParseView()
    }
}
