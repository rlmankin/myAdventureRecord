//
//  BParseRow.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 3/9/21.
//

import SwiftUI

struct BParseRow: View {
	@State  var bpFile : ReturnStruct		// @State is required, due to Toggle(isOn:) requiring a Binding<Bool>
	
    var body: some View {
		
		timeStampLog(message: "-> BParseRow")
		
		return
			HStack (spacing: 3){
				Toggle(isOn: $bpFile.parseThis, label: {
					EmptyView()
				})
				//	name of file
				Text("\(bpFile.url.lastPathComponent) ")
					.frame(width:350, alignment: .leading)
				//	date file was created
				Text(bpFile.creationDate, style: .date)
					.frame(width: 100, alignment: .trailing)
				//	if the parse is not completed output progress view wheel
				if bpFile.parseInProgress == ReturnStruct.parseProgress.inProgress {
					ProgressView()
						.frame(width: 30, height: 30)
				}
				//	if the parse is completed, output the number of tracks, the number of trackpoints in each track,
				//		the db track row numbers where the track was inserted into the db, and
				//		the db trkpt row numbers where the trkptList was inserted.
				if bpFile.parseInProgress == ReturnStruct.parseProgress.done {
					HStack (spacing: 0) {
						Text("\(bpFile.numTracks): [")
						
						
						if bpFile.trackdbRow.count >= 1 {
							if bpFile.numTracks >= 1 {
								ForEach (1 ... bpFile.numTracks, id: \.self) { itemIndex in
									Text("\(bpFile.numTrkpts[itemIndex]); \(bpFile.trackdbRow[itemIndex]); \(bpFile.advdbRow[itemIndex])]")
								}
							}
						}
					}
				}
			}.foregroundColor(bpFile.color)
			
    }
}


struct BParseRow_Previews: PreviewProvider {
    static var previews: some View {
		BParseRow(bpFile: ReturnStruct(url:URL(string:"blah")!,
									   parseThis: true,
									   creationDate: Date(),
									   parseInProgress: .done,
									   numTrkpts: [1],
									   trackdbRow: [2],
									   advdbRow: [3]))
    }
}

