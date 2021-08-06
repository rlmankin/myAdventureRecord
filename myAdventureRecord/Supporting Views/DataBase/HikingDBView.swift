//
//  HikingDBView.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 1/26/21.
//

import SwiftUI

struct HikingDBView: View {
    var body: some View {
		timeStampLog(message: "-> DBViewControllerRepresentable")
        return DBViewControllerRepresentable()
    }
}

struct HikingDBView_Previews: PreviewProvider {
    static var previews: some View {
        HikingDBView()
    }
}
