//
//  BPListView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 3/9/21.
//

import SwiftUI


struct BPListView: View {
	@EnvironmentObject var bpFiles : BPFiles
	
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
					BParseRow(bpFile: bpFiles.xmlFiles[fileIndex])
				}
				
			}
    }
}

struct BPListView_Previews: PreviewProvider {
    static var previews: some View {
        BPListView()
			.environmentObject(BPFiles())
    }
}
