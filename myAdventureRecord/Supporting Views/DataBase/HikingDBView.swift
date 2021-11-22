//
//  HikingDBView.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 1/26/21.
//

import SwiftUI

struct HikingDBView: View {
	@Binding var stateFlag : FlagStates?
    var body: some View {
		timeStampLog(message: "-> DBViewControllerRepresentable")
        return
		VStack (alignment: .leading){
			Button( action: {
				stateFlag = FlagStates.empty
			}) { Text("Cancel").padding(2)}
			DBViewControllerRepresentable()
		}
    }
}

struct HikingDBView_Previews: PreviewProvider {
    static var previews: some View {
		HikingDBView(stateFlag: .constant(.showDBTable))
    }
}
