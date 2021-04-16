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
	@Published var initComplete = false
	
	func add(_ track: Track) {
		let adventure = loadAdventureTrack(track: track)
		self.adventures.append(adventure)
		self.reload()
		self.adventures.sort( by: { $0.trackData.trackSummary.startTime! >= $1.trackData.trackSummary.startTime!})
		
	}
	
	func reload() {
		for item in self.adventures {
			print("reload:  prereload[ \(item.name)")
		}
		sqlHikingData.reloadTracks()
		adventureData = loadAdventureData()
		adventures = adventureData
		self.adventures.sort( by: { $0.trackData.trackSummary.startTime! >= $1.trackData.trackSummary.startTime!})
		
		for item in self.adventures {
			print("reload:  postreload \(item.name)")
		}
	}
	
	
}
