//
//  BParseRow.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 3/9/21.
//

import SwiftUI

struct BParseRow: View {
	@EnvironmentObject var bpFiles : BPFiles
	var index : Int
	
	
    var body: some View {
		print("BPRow  body: \(bpFiles.xmlFiles[index].color)")
		return HStack (spacing: 3){
			//	name of file
			Text("\(bpFiles.xmlFiles[index].url.lastPathComponent) ")
				.frame(width: 350, alignment: .leading)
			//	date file was created
			Text(bpFiles.xmlFiles[index].creationDate, style: .date)
				.frame(width: 100, alignment: .trailing)
			//	if the parse is not completed output progress view wheel
			if bpFiles.xmlFiles[index].parseInProgress == ReturnStruct.parseProgress.inProgress {
				ProgressView()
					.frame(width: 30, height: 30)
			}
			//	if the parse is completed, output the number of tracks, the number of trackpoints in each track,
			//		the db track row numbers where the track was inserted into the db, and
			//		the db trkpt row numbers where the trkptList was inserted.
			if bpFiles.xmlFiles[index].parseInProgress == ReturnStruct.parseProgress.done {
				let xmlFile = bpFiles.xmlFiles[index]						// temporary to not have to type bpFiles... every time
				HStack (spacing: 0) {
					Text("\(xmlFile.numTracks): [")
					ForEach (1 ... xmlFile.numTrkpts.count - 1, id: \.self) { itemIndex in
						Text("\(xmlFile.numTrkpts[itemIndex])")
						if itemIndex < xmlFile.numTrkpts.count-1 { Text(", ")}	// add ", " except on the last iteration
						
					}
					Text("]")
					if xmlFile.trackRow.count > 1 {
						Text(": ")
						ForEach (1 ... xmlFile.trackRow.count - 1, id: \.self) { itemIndex in
							Text("\(xmlFile.trackRow[itemIndex]) ")
							if itemIndex < xmlFile.trackRow.count-1 { Text(", ")}// add ", " except on the last iteration
							
						}
						ForEach (1 ... xmlFile.trkptRow.count - 1, id: \.self) { itemIndex in
							Text("\(xmlFile.trkptRow[itemIndex]) ")
							
						}
					Text("], ")
					}
					
					
				}
			}
		}.foregroundColor(bpFiles.xmlFiles[index].color)
    }
}

struct BParseRow_Previews: PreviewProvider {
    static var previews: some View {
		BParseRow(index: 0)
			.environmentObject(BPFiles())
    }
}
