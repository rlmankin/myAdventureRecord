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
	
	func add(_ track: Track) {
		let adventure = loadAdventureTrack(track: track)
		self.adventures.append(adventure)
		print("adventure count \(self.adventures.count), \(self.adventures[self.adventures.count - 1].name)")
	}
	
}
