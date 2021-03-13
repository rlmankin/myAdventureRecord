//
//  BPListView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 3/9/21.
//

import SwiftUI


struct BPListView: View {
	@EnvironmentObject var bpFiles : BPFiles
	//@Binding var xmlFiles : [ReturnStruct]
	
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
		print("bPList body:  \(bpFiles.xmlFiles.map {$0.color})")
		return
			Group {
				List (0 ... bpFiles.xmlFiles.count-1, id:\.self) { fileIndex in
						BParseRow(index: fileIndex)
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
