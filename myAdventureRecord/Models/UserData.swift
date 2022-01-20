//
//  UserData.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/10/20.
//

import Combine
import SwiftUI

final class	UserData: ObservableObject {
	@Published var adventures : [Adventure] //= adventureData
	
	init() {
		self.adventures = []
	}
	
	func reload(tracksOnly: Bool = false) {
		adventureData = loadAdventureData()
		self.adventures = adventureData
	}
	
	func append(item: Track) {
		self.adventures.append(loadAdventureTrack(track: item))
		adventures.sort( by: { $0.trackData.trackSummary.startTime! >= $1.trackData.trackSummary.startTime!})		// crashes when no startTime  11/30/21
		//self.reload()
	}
	
	func loadUserData() async -> Void {
		self.adventures = adventureData
	}
	
	func getTpListfromDb(index: Int, id: Int) async -> Void {
		self.adventures[index].trackData.trkptsList = sqlHikingData.sqlRetrieveTrkptlist(id)
	}
	
	
	
}
