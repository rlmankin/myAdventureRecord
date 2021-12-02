//
//  BPListView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 3/9/21.
//

import SwiftUI


struct BPListView: View {
	//@EnvironmentObject var bpFiles : BPFiles
	@Binding var bpFiles : BPFiles
	
	
	func colorToString( color: Color) -> String {
		switch color {
		case Color.yellow:
			return "yellow"
		case Color.pink :
			return "pink"
		case Color.green :
			return "green"
		default:
			return "white"
		}
	}
    var body: some View {
		return
			Group {
				List (0 ..< bpFiles.xmlFiles.endIndex, id:\.self) { fileIndex in
					HStack {
						Toggle(isOn: $bpFiles.xmlFiles[fileIndex].parseThis, label: {
							EmptyView()
						})
						Text("\(bpFiles.xmlFiles[fileIndex].url.lastPathComponent) ")
							.frame(width:350, alignment: .leading)
						//	date file was created
						Text(bpFiles.xmlFiles[fileIndex].creationDate, style: .date)
							.frame(width: 100, alignment: .trailing)
						//	if the parse is not completed output progress view wheel
						if bpFiles.xmlFiles[fileIndex].parseInProgress == ReturnStruct.parseProgress.inProgress {
							ProgressView()
								.frame(width: 30, height: 30)
						}
						//	if the parse is completed, output the number of tracks, the number of trackpoints in each track,
						//		the db track row numbers where the track was inserted into the db, and
						//		the db trkpt row numbers where the trkptList was inserted.
						if bpFiles.xmlFiles[fileIndex].parseInProgress == ReturnStruct.parseProgress.done {
							HStack (spacing: 0) {
								Text("\(bpFiles.xmlFiles[fileIndex].numTracks): [")
								
								
								if bpFiles.xmlFiles[fileIndex].trackdbRow.count >= 1 {
									if bpFiles.xmlFiles[fileIndex].numTracks >= 1 {
										ForEach (1 ... bpFiles.xmlFiles[fileIndex].numTracks, id: \.self) { itemIndex in
											Text("\(bpFiles.xmlFiles[fileIndex].numTrkpts[itemIndex]); \(bpFiles.xmlFiles[fileIndex].trackdbRow[itemIndex]); \(bpFiles.xmlFiles[fileIndex].advdbRow[itemIndex])]")
										}
									}
								}
							}
						}

						//BParseRow(bpFiles.xmlFiles[fileIndex]: bpFiles.xmlFiles[fileIndex]s.xmlFiles[fileIndex])
					}
					
				}
				
			}
    }
}

struct BPListView_Previews: PreviewProvider {
    static var previews: some View {
		BPListView(bpFiles: .constant(BPFiles()))
    }
}
