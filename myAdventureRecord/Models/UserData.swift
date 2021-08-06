//
//  UserData.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/10/20.
//

import Combine
import SwiftUI

final class	UserData: ObservableObject {
	@Published var adventures = adventureData
	
	func reload(tracksOnly: Bool = false) {
		adventureData = loadAdventureData()
		self.adventures = adventureData
	}
	
	func append(item: Track) {
		var localAdventure = loadAdventureTrack(track: item)
		self.adventures.append(localAdventure)
		adventures.sort( by: { $0.trackData.trackSummary.startTime! >= $1.trackData.trackSummary.startTime!})
	}
	
	
}
