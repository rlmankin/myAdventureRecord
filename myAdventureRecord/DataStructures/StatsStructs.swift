//
//  StatsStructs.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/6/20.
//

import Foundation
struct MinMaxStats: Codable, Hashable {
	struct Stat: Codable, Hashable {
		var statData: Double
		
		var boundedStatData: Double{
			get {
				switch self.statData {
				case Double.greatestFiniteMagnitude:
					return 0
				case -Double.greatestFiniteMagnitude:
					return 0
				default:
					return self.statData
				}
			}
			
		}
		var startIndex : Int
		var endIndex: Int
		
		init (startVal: Double) {
			self.statData = startVal
			self.startIndex = 0
			self.endIndex  = 0
		}
		
	}
	
	var max = Stat(startVal: -Double.greatestFiniteMagnitude)					//	init max to the largest negative number available
	var min = Stat(startVal: Double.greatestFiniteMagnitude)					//	init min to the largest postivie number available
	var avg = Stat(startVal: 0)
	
}



struct MileageStats: Codable, Hashable {
	var grade = MinMaxStats()
	var speed =  MinMaxStats()
	var ascent =  MinMaxStats()
	var ascentRate = MinMaxStats()
	var descent = MinMaxStats()
	var descentRate = MinMaxStats()
}
