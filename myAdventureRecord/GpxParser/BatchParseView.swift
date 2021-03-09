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
			}
		}
	}
}


struct BatchParseView: View {
	
	@EnvironmentObject var parseGPX :  parseController
	@State private var startDate = Date()
	@State private var endDate = Date()
	@State private var xmlFiles = [ReturnStruct]()
	@State private var xmlFilesAvailable : Bool = false
	@State private var nowParsing : Bool = false
	
	struct ReturnStruct {
		var url: URL
		var creationDate: Date
		var parseColor: Color
	}
	
	func getFile(startDate: Date, endDate: Date) -> [ReturnStruct]
	{
		
		var returnItem = ReturnStruct(url:URL(string:"blah")!, creationDate: Date(), parseColor: Color.white)
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
	
	func parseAndInsertParseList( fileArray: [ReturnStruct], insert: Bool) -> Bool {
		
		let parseGPX = parseController()
		for fileIndex in (0 ... fileArray.count - 1) {
			print("Parsing \(fileArray[fileIndex].url)")
			let  parseSuccess = parseGPX.parseSingleFile(fileArray[fileIndex].url)
			if parseSuccess {
					if insert {
						for track in parseGPX.parsedTracks {
						//track.print()
						let trackDb = SqlHikingDatabase()		//	open and connect to the hinkingdbTable of the SQL hiking database
						let trkptDb = SqlTrkptsDatabase()		//	connect to the trkptsTable of the SQL hiking database
						let trackRow = trackDb.sqlInsertDbRow(track)
						let trkptRow = trkptDb.sqlInsertTrkptList(trackRow, track.trkptsList)
						print("GPX file: \(track.header) - inserted @ row: \(trackRow), trkPts @ row: \(trkptRow)")
						}
					}
			}
		}
		
		return true
	}
	
	
	
    var body: some View {
	
		GetDateView(startDate: $startDate, endDate: $endDate)
			
		if !xmlFilesAvailable {
			Button( action: {
				xmlFiles = getFile(startDate: startDate, endDate: endDate)
				xmlFilesAvailable = !xmlFiles.isEmpty
			 })
			 { Text("find files")}
		} else {
			Button( action: {
						parseAndInsertParseList(fileArray: xmlFiles, insert: false)
						nowParsing.toggle()
				})
				{	Text("parse files") }
			List {
				if !xmlFiles.isEmpty {
					ForEach (0 ... xmlFiles.count-1, id:\.self) { fileIndex in
						HStack (spacing: 3){
							Text("\(xmlFiles[fileIndex].url.lastPathComponent): ")
							Text(xmlFiles[fileIndex].creationDate, style: .date)
						}
					}
				}
			}
			
		}
		
		
		
    }
}

struct BatchParseView_Previews: PreviewProvider {
    static var previews: some View {
        BatchParseView()
    }
}
