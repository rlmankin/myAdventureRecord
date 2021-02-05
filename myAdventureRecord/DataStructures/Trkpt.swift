//
//  Trkpt.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/6/20.
//

import Foundation

struct Trkpt: Codable, Hashable, Identifiable {
	
	var id = UUID()
	
	// There are three structures to hold the necessary information for three separate scenarios.
	//		The FromValidEleTime is used to hold properties used in calculating ascent/decent rate and can only be valid if there is time & elevation.
	//			This structure does NOT contain distance or trailSpeed but only gain and gainSpeed.
	//		The FromValidDistTime is used to hold properties use in calculating over-the-trail speed which is valid whenever there is a valid timestamp
	//			because there are always valid longitude and latitude properties to calculate distance
	//		The FromLastTrkPt is used to hold the only 'guaranteed' parameter in a track; distance
	struct FromValidEleTime : Codable, Hashable{
		var lastValidIndex: Int												// the index of the trackpoint that has the last valid timestamp & valid elevation
		var distance: Double
		var gain: Double														// the vertical gain between the last valid timestamped trackpoint and the current trackpoint
																				//		(difference in elevation)
		var elapsedTime: TimeInterval											// the time differential between from the last valid timestamped trackpoint the last valid
																				//		timestamped trackpoint and the current trackpoint
		var gainSpeed: Double {													// the speed overwhich the gain was achieved (can be +/- depending on ascent/descent)
			get {
				assert(elapsedTime != 0, "invalid get in FromValidEleTime")
				return gain / elapsedTime
			}
		}
		init() {																// the structure's initializer
			lastValidIndex = -1												// a negative index indicates and invalid index
			distance = -1.0
			gain = 0.0
			elapsedTime = TimeInterval(0.0)										// should the structure not be written before the getter 'gainSpeed' is accessed an assert will trigger
		}
	}
	
	struct FromValidDistTime: Codable, Hashable {
		var lastValidIndex: Int												// the index of the trackpoint that has the last valid timestamp
		var distance: Double													// the over the trail distance from the last valid timestamped trackpoint to this trackpoint
		var elapsedTime: TimeInterval											// the time differential between from the last valid timestamped trackpoint and the current trackpoint
		var trailSpeed: Double {												// the speed overwhich the distance was traveled
			get {
				//assert((elapsedTime != 0) && (lastValidIndex != -1)), "trailSpeed assertion: elapsedTime = 0, lastValidIndex = \(lastValidIndex)")
				if elapsedTime != 0 {
					return distance / elapsedTime
				} else {
					print("trailSpeed assertion: elapsedTime = 0, lastValidIndex = \(lastValidIndex)")
					return 0
				}
			}
		}
			
		init() {																// the structure's initializer
			lastValidIndex = -1												// a negative index indicates and invalid index
			distance = 0.0
			elapsedTime = TimeInterval(0.0)										// 	should the structure not be written before the
																				//	getter 'trailSpeed' is accessed an assert will trigger
		}
	}
	
	struct FromValidEleTrkPt: Codable, Hashable {
		var lastValidIndex: Int												// the index of the last valid elevation trackpoint
		var distance: Double													// the distance from this trakpoint to the last valid
																				//	NOTE: there is no time associated with this structure
		var gain: Double
		var elapsedTime : TimeInterval
		
		init() {
			lastValidIndex = -1
			distance = 0.0
			gain = 0.0
			elapsedTime = TimeInterval(-1.0)
		}
	}
	
	struct FromLastTrkPt : Codable, Hashable {
		var lastValidIndex: Int													// the index of the previous trackpoint
		var distance: Double													// the distance from the previous trackpoint to this trackpoint
		var gain: Double
		
		init() {
			lastValidIndex = -1
			distance = 0.0
			gain = 0.0
		}
	}
	
	struct StatisticsTrkPt: Codable, Hashable {
		var lastValidIndex: Int												// the index of the last valid elevation trackpoint
		var distance: Double													// the distance from this trakpoint to the last valid
																				//	NOTE: there is no time associated with this structure
		var gain: Double
		var elapsedTime : TimeInterval
		
		init() {
			lastValidIndex = -1
			distance = 0.0
			gain = 0.0
			elapsedTime = TimeInterval(-1.0)
		}
	}
	
	// properties read from the .gpx
	var index: Int																// every trackpoint has an index associated with it.
																				//	this is used to determine a values location in a trkpt array
	
	//	Will need to add some kind of unique identifier, separate from index to make trkpt 'Identifiable'.  UUID?
		// 	Note: the following flags exist to recreate & debug time based properties
	var hasValidElevation: Bool													// flag to indicate that this trackpoint has a valid Elevation property
	var hasValidTimeStamp: Bool													// flag to indicate that this trackpoint has a valid Timestamp
	var latitude: Double														// every .gpx trackpoint will have entry for latitude
	var longitude: Double														// every .gpx trackpoint will have entry for longitude
	var elevation: Double?														// not every .gpx trackpoint will have an elevation associated with it; therefore optional
	var timeStamp: Date?
	var lastTimeEleTrkpt: FromValidEleTime
	var lastTimeDistTrkpt: FromValidDistTime
	var lastEleTrkpt: FromValidEleTrkPt
	var lastTrkpt: FromLastTrkPt
	var statisticsTrkpt: StatisticsTrkPt
	
	
	
	// not every .gpx trackpoint will have an timestamp associated with it; therefore optional
	
	
	init() {
		index = -1																//	a negative index indicates an invalid index
		hasValidElevation = false												//  init to false (i.e. insures that a valid elevation must be found)
		hasValidTimeStamp = false												//	init to false (i.e. insures that a valide timestamp must be found)
		latitude = 0.0															//	init latitude
		longitude = 0.0															//	init longitude
		elevation = nil															//	init elevation optional to nil
		timeStamp = nil															//	init time optional to nil
		lastTimeEleTrkpt = FromValidEleTime()
		lastTimeDistTrkpt = FromValidDistTime()
		lastEleTrkpt = FromValidEleTrkPt()
		lastTrkpt = FromLastTrkPt()
		statisticsTrkpt = StatisticsTrkPt()
	}
	
	mutating func copyToStatisticsStruct(_ sourceStruct : String ) -> Bool{
		
		switch sourceStruct {
		case "EleTime" :	self.statisticsTrkpt.lastValidIndex = self.lastTimeEleTrkpt.lastValidIndex
							self.statisticsTrkpt.distance = self.lastTimeEleTrkpt.distance
							self.statisticsTrkpt.elapsedTime = self.lastTimeEleTrkpt.elapsedTime
							self.statisticsTrkpt.gain = self.lastTimeEleTrkpt.gain
			return true
		case "DistTime" :	self.statisticsTrkpt.lastValidIndex = self.lastTimeDistTrkpt.lastValidIndex
							self.statisticsTrkpt.distance = self.lastTimeDistTrkpt.distance
							self.statisticsTrkpt.elapsedTime = self.lastTimeDistTrkpt.elapsedTime
							//self.statisticsTrkpt.gain = self.lastTimeDistTrkpt.gain
			return true
		case "Ele" : 		self.statisticsTrkpt.lastValidIndex = self.lastEleTrkpt.lastValidIndex
							self.statisticsTrkpt.distance = self.lastEleTrkpt.distance
							self.statisticsTrkpt.elapsedTime = self.lastEleTrkpt.elapsedTime
							self.statisticsTrkpt.gain = self.lastEleTrkpt.gain
			return true
		case "LastTrkPt" :	self.statisticsTrkpt.lastValidIndex = self.lastTrkpt.lastValidIndex
							self.statisticsTrkpt.distance = self.lastTrkpt.distance
							//self.statisticsTrkpt.elapsedTime = self.lastTrkpt.elapsedTime
							self.statisticsTrkpt.gain = self.lastTrkpt.gain
			return true
		
		default: return false
		}
	}
	
	func prettyPrint() {

		var outputstring : String = ""
		var tpele: String = ""
		let trkpt = self
		let hvele = String(trkpt.hasValidElevation)
		let hvtime = String(trkpt.hasValidTimeStamp)
		if let elevation = trkpt.elevation {
			 tpele = String(elevation)
		} else {
			 tpele = "nil"
		}
		outputstring.append(String(format: " indx: %2d,hvele: %@, hvtime: %@, tpele: %@, lat: %4.0f, lon: %4.0f\n",trkpt.index, hvele, hvtime, tpele, trkpt.latitude, trkpt.longitude))
		outputstring.append(String(format: "\tlastTrkPt: indx:%2d, dist:%4.0f\n", trkpt.lastTrkpt.lastValidIndex, trkpt.lastTrkpt.distance))
		outputstring.append(String(format: "\tlastTimeDistTrkPt: vindex:%2d, dist:%4.0f, et: %4.1f, tspd: %4.2f \n", trkpt.lastTimeDistTrkpt.lastValidIndex,
										trkpt.lastTimeDistTrkpt.distance, trkpt.lastTimeDistTrkpt.elapsedTime, trkpt.lastTimeDistTrkpt.trailSpeed))
		outputstring.append(String(format: "\tlastTimeEleTrkPt: vindex: %2d, gain: %4.0f, et: %4.5f, gspd: %4.2f \n\n", trkpt.lastTimeEleTrkpt.lastValidIndex,
										trkpt.lastTimeEleTrkpt.gain, trkpt.lastTimeEleTrkpt.elapsedTime, trkpt.lastTimeEleTrkpt.gainSpeed))
			
		print(outputstring)
	}
}
