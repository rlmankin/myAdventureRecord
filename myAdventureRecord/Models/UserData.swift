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
	
	
}
