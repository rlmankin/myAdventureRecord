//
//  parseGPXXML.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 2/10/21.
//

//  This is the 'guts' of the hikingdbWin program.  This class parse a .gpx file to create a set of points
//		to be used to determine various track statistics.  This was heavily leveraged from a python version
//		This uses the Foundation capability to read XML

//	This file was copy/pasted from doHikingDb.  I did this in order to remove the dependencies of a documented-based app (like doHikingDbWin)
//		to a SwiftUI framework.  Assumption is to remove all document based elements and replace with an 'appropriate' SwiftUI construct
import Foundation
import CoreLocation
import SwiftUI


//***  Comment flag for items commented out from original file


//
//  copied from doHikingDB/trkptUtilities.swift
//  Robb Mankin on 2/10/21

import Foundation
import CoreLocation

func calcDistance(_ currentTrkpt: Trkpt, _ lastTrkpt: Trkpt) -> Double {		// Calculate the distance between two trackpoints
																				// inputs are two trackpoints.  No range checking is preformed because
																				// all trackpoints will have longitude and latitude.
	let currentLocation = CLLocation(latitude: currentTrkpt.latitude, longitude: currentTrkpt.longitude)
	let previousLocation = CLLocation(latitude: lastTrkpt.latitude,	  longitude: lastTrkpt.longitude)
	return currentLocation.distance(from: previousLocation)				// return value is the distance
}

func calcGain(_ currentTrkpt: Trkpt, _ lastTrkpt: Trkpt) -> Double? {			// Calculate the gain between two trackpoints, return Double
	if let elevation1 = currentTrkpt.elevation {								//	Since .elevation may be nil, use optional binding,
		if let elevation2 = lastTrkpt.elevation {
			return elevation1 - elevation2
		}
	}
	return nil																	// return nil if either or both .elevation values are nil
}

func calcElapsedTime(_ currentTrkpt: Trkpt, _ lastTrkpt: Trkpt) -> TimeInterval {	// Calculate the elapsed time between two trackpoints, return TimeInterval
	if let time1 = currentTrkpt.timeStamp {										//	Since .timeStamp may be nil use optional binding
		if let time2 = lastTrkpt.timeStamp {
			return time1.timeIntervalSince(time2)
		}
	}
	return -1																	//	return -1 if either or both .timeStamps are nil
																				//	Should probably fix this to return TimeInterval?
}

//	****************************************************************************
func calculateTrkProperties(_ currentTrack: inout Track) {						//  Main track property calculations
	//  Determine all summary level totals (ascent, descent, distance
	//	For those tracks which have valid time and elevation data
	//	Sequence through the validTimeAndEleArray to calculate the the distance, gain, and speed for all possible legs
	
	//	Determine if there is either enough time and elevation datapoints or enough elevation only datapoints to calculate total
	//		ascent and descent
	currentTrack.validTrkptsForStatistics = currentTrack.trkptsList
					.filter({$0.hasValidTimeStamp && $0.hasValidElevation})		//  get only those trackpoints that have a valid elevation and a valid timeStamp
	let validElevationArray = currentTrack.trkptsList.filter({$0.hasValidElevation})
	if currentTrack.validTrkptsForStatistics.count < 2 {										// not enough time and elevation trackpoints
		currentTrack.noValidTimeEle = true
		//print("not enough TimeAndEle")
		if validElevationArray.count >= 2 {										// check if there is enough elevation trackpoints
			currentTrack.validTrkptsForStatistics = validElevationArray
			for i in 0 ... currentTrack.validTrkptsForStatistics.count - 1  {
				guard currentTrack.validTrkptsForStatistics[i].copyToStatisticsStruct("Ele") else { return }
			}

			//print("using validElevationArray")
		} else {
			currentTrack.noValidEle = true
			return																//	early return if there are not enough entries in the ValidTimeAndEleArray
		}
	} else {
		for i in 0 ... currentTrack.validTrkptsForStatistics.count - 1 {
			guard currentTrack.validTrkptsForStatistics[i].copyToStatisticsStruct("EleTime") else { return }
		}
		//print("using validTimeElevationArray")
	}
	
	if !currentTrack.noValidTimeEle {
		currentTrack.trackSummary.totalAscentTime =
				currentTrack.trkptsList.compactMap({$0.lastTimeEleTrkpt.elapsedTime})	// .compactMap removes all nil entries
					.filter({$0 >= 0}).reduce(0,+)								// ,filter get only those values >= 0, .reduce sums the result
		currentTrack.trackSummary.totalDescentTime =
				currentTrack.trkptsList.compactMap({$0.lastTimeEleTrkpt.elapsedTime})	// .compactMap removes all nil entries
					.filter({$0 < 0}).reduce(0,+)								// ,filter get only those values >= 0, .reduce sums the result
		currentTrack.trackSummary.totalAscent =
				currentTrack.trkptsList.compactMap({$0.lastTimeEleTrkpt.gain})	// .compactMap removes all nil entries
					.filter({$0 >= 0}).reduce(0,+)								// ,filter get only those values >= 0, .reduce sums the result
		currentTrack.trackSummary.totalDescent =
				currentTrack.trkptsList.compactMap({$0.lastTimeEleTrkpt.gain})	// .compactMap removes all nil entries
					.filter({$0 < 0}).reduce(0,+)								// ,filter get only those values >= 0, .reduce sums the result
		currentTrack.trackSummary.distance =
				currentTrack.trkptsList.compactMap({$0.lastTrkpt.distance}).reduce(0,+)// .compactMap removes all nil entries, sum all distances
		currentTrack.trackSummary.avgAscentRate = (currentTrack.trackSummary.totalAscentTime != 0 ?
				(currentTrack.trackSummary.totalAscent / currentTrack.trackSummary.totalAscentTime) : 0)// ternary assignment (condition ? assigniftrue: assigniffalse)
		currentTrack.trackSummary.avgDescentRate = (currentTrack.trackSummary.totalDescentTime != 0 ?
				(currentTrack.trackSummary.totalDescent / currentTrack.trackSummary.totalDescentTime) : 0)	// ternary assignment (condition ? assigniftrue: assigniffalse)
		currentTrack.trackSummary.netAscent = currentTrack.trackSummary.totalAscent + currentTrack.trackSummary.totalDescent
		currentTrack.trackSummary.avgSpeed = (currentTrack.trackSummary.duration != 0 ? currentTrack.trackSummary.distance / 	currentTrack.trackSummary.duration : 0)	//time related
	}
	
	if !currentTrack.noValidEle {
		currentTrack.trackSummary.totalAscent =
				currentTrack.trkptsList.compactMap({$0.lastEleTrkpt.gain})	// .compactMap removes all nil entries
					.filter({$0 >= 0}).reduce(0,+)								// ,filter get only those values >= 0, .reduce sums the result
		currentTrack.trackSummary.totalDescent =
				currentTrack.trkptsList.compactMap({$0.lastEleTrkpt.gain})	// .compactMap removes all nil entries
					.filter({$0 < 0}).reduce(0,+)								// ,filter get only those values >= 0, .reduce sums the result
		currentTrack.trackSummary.distance =
				currentTrack.trkptsList.compactMap({$0.lastTrkpt.distance}).reduce(0,+)// .compactMap removes all nil entries, sum all distances
		
	}
	
	//	Determine all summary elevation stats (start, max, min) and start/end time properties
	if let startElevation = currentTrack.trkptsList.compactMap({$0.elevation}).first {
		currentTrack.trackSummary.startElevation = startElevation				// if there are no recorded elevations .first will return nil, thus need optional binding
	}
	if let startTimeStamp = currentTrack.trkptsList.compactMap({$0.timeStamp}).first {
		currentTrack.trackSummary.startTime = startTimeStamp					// if there are no recorded times .first will return nil, thus need optional binding
	}
	if let endTimeStamp = currentTrack.trkptsList.compactMap({$0.timeStamp}).last {
		currentTrack.trackSummary.endTime = endTimeStamp						// if there are no recorded times .last will return nil, thus need optional binding
	}
	if let tmpStart = currentTrack.trackSummary.startTime, let tmpEnd = currentTrack.trackSummary.endTime {
			currentTrack.trackSummary.duration = tmpEnd.timeIntervalSince(tmpStart)// if there are no recorded times return nil, thus need optional binding
	}
	currentTrack.trackSummary.avgSpeed = (currentTrack.trackSummary.duration != 0 ? currentTrack.trackSummary.distance / currentTrack.trackSummary.duration : 0)
																				// ternary assignment (condition ? assigniftrue: assigniffalse)
					// Min,Max Elevation calculations
	if let maxElevation = currentTrack.trkptsList.compactMap({$0.elevation}).max() {	// .compactMap removes all nil entries
		currentTrack.trackSummary.elevationStats.max.elevation = maxElevation	// no need to option bind because nil entries have been removed
		currentTrack.trackSummary.elevationStats.max.index =
			currentTrack.trkptsList.firstIndex(where: {$0.elevation == maxElevation})!	// since a maxElevation was found, there is no need for a nil check
	}
	if let minElevation = currentTrack.trkptsList.compactMap({$0.elevation}).min() {	// .compactMap removes all nil entries
		currentTrack.trackSummary.elevationStats.min.elevation = minElevation	// no need to option bind because nil entries have been removed
		currentTrack.trackSummary.elevationStats.min.index =
			currentTrack.trkptsList.firstIndex(where: {$0.elevation == minElevation})!	// since a minElevation was found, there is no need for a nil check
	}
}

//	This method finds the minimum and maximium values in an array, then sets the approporiate minMax structure values
func setMinMax(_ sourceArray: inout [LegStatsStruct], _ targetParm: inout MinMaxStats, closure: (LegStatsStruct) -> (Double), loopCount: Int, closureNum: Int) {
																				// input is a sourceArray of LegStatsStruct
																				//		targetParm is a single element of a MinMaxStats structure to place the specific stats
																				//		closure is a closure that is used to help map a specific LegStatsStruct element from
																				//			the sourceArray
																				//		loopcount is a debug variable passed to indicate which trackpoint is being worked on
																				//		closureNum is debug variable passed to indicate which LegStatsStruct element is being requested
	let debugVar = sourceArray.map(closure)										//  creates an array of the DListStruct element under examination.  E.g. gain, speed, ascent, descent, ...
			//  In order to deal with various (Double) variables that should hold the same value, but don't create a new array from the sourceArray(debugVar) that creates an Integer that is the
			//		value multiplied by 1 million.  This should allow for successfully finding all indexes associated with maximum and minimum values.  This was required to address the periodic
			//		failure of the statIndex = debugVar.Index(of: <var>) to successfully find the index of the maximum/minimum values, due to imprecision of converting Doubles
	//Swift.print("loopCount = \(loopCount) closure#: \(closureNum)")
	guard !debugVar.isEmpty else {
		return
	}
	let mappedArray = debugVar.map({Int($0*1e6)})								// create an integer & multiply values by 1 million
	let debugVarMax = mappedArray.reduce(Int.min,max)							// find the maximum
	let debugVarMin = mappedArray.reduce(Int.max, min)							// find the minimum
	var statIndex = mappedArray.firstIndex(of: debugVarMax)!					// find the index of the maximum.  OK to force unwrap because I know the value exists
																// the force unwrap fails on CHeyenne Mountain hike  need to investigate
	targetParm.max.statData = max(targetParm.max.statData, debugVar[statIndex])	// set the statdata field to the actual value of the maximum, not the 1e6 multiple
	targetParm.max.startIndex = sourceArray[statIndex].startIndex				// set the start/end index values fromthe original sourceArray
	targetParm.max.endIndex = sourceArray[statIndex].endIndex
		// find minimum index
	statIndex = mappedArray.firstIndex(of: debugVarMin)!						// find the index of the minimum.  OK to force unwrap because I know the value exists
	targetParm.min.statData = min(targetParm.min.statData, debugVar[statIndex])	// set the statdata field to the actual value of the maximum, not the 1e6 multiple
	targetParm.min.startIndex = sourceArray[statIndex].startIndex				// set the start/end index values fromthe original sourceArray
	targetParm.min.endIndex = sourceArray[statIndex].endIndex
}

//	LegStatsStruct is the structure used to collect all relevant parts of a leg or segment of a track.
struct LegStatsStruct {
	var startIndex: Int															// start index of the leg
	var endIndex: Int															// end index of the leg
	var distance: Double														// distance between start and end
	var elapsedTime: TimeInterval												// elapsedTime between start and end
	var gain: Double															// elevation difference between start and end
	var grade : Double {														// a getter used to calcuate the grade between start and end, return 0 if distance is 0
		get {
			return (distance != 0 ? gain/distance : 0.0)
		}
	}
	var gradeSpeed : Double {													// a getter used to calculate the vertical speed over the lef, return 0 if elapsedTime is 0
		get {
			return  (elapsedTime != 0 ? gain/elapsedTime : 0.0)
		}
	}
	var ascent : Double															// sum of meters gained for every point between the start and end.
	var ascentElapsedTime: TimeInterval											// time spent ascending
	var ascentSpeed : Double {													// a getter used to caclulate the average speed of the ascent, return 0 if elapsedTime is 0
		get {
			return (ascentElapsedTime != 0 ? ascent / ascentElapsedTime : 0)
		}
	}
	var descent : Double														// sum of meters lost for every point between the start and end
	var descentElapsedTime: TimeInterval										// time spend descending
	var descentSpeed : Double {													// a getter used to calcuate the average speed of the descent, return 0 if elapsedTime is 0
		get {
			return (descentElapsedTime != 0 ? descent / descentElapsedTime : 0)
		}
	}
	var trailSpeed : Double {													// a getter used to calculare the overall 'flatland' speed between start and end
		get {
			return (elapsedTime != 0 ? distance / elapsedTime : 0)				// 		return - if elapsedTime is 0
		}
	}
	
	init() {
		self.startIndex = -1													// invalid startIndex
		self.endIndex = -1														// invalid endIndex
		self.distance = 0.0														// all other values init to 0.0
		self.elapsedTime = 0.0
		self.gain = 0.0
		self.ascent = 0.0
		self.ascentElapsedTime = 0.0
		self.descent = 0.0
		self.descentElapsedTime = 0.0
	}
}

//	main function to create all mileage based statistics
//*** func createMileageStats(_ currentTrack: inout Track, _ parentViewController:  Document?) {
func createMileageStats(_ currentTrack: inout Track) {
																				// input is the track currently being processed
																				//	and the pointer to the overall ViewController (used only by Notification to update the progress bar

	var overEighthMile = [LegStatsStruct]()										// Collection of all track segments (leg) that are between 1/8 and 3/16 of a mile
	var overMile = [LegStatsStruct]()											// Collection of all track segments that are at least one mile in length
	var eighthStats = MileageStats()											// local temporary variable to hold the 1/8 mile min/max values for all calculated stat
	var mileStats = MileageStats()												// local temporary variable to hold the 1 mile min/max values for all calculated stats
					//	initializers
	var avgDescentRateMile = 0.0
	var avgAscentRateMile = 0.0
	let progressBarMax = Double(currentTrack.trkptsList.count)					// the maximum value used by the deterministic progress bar in the View
	let progressBarMin = 0.0													// used by the progressBar
	let progressBarIncr = 1.0													// used by the progressBa	let userInfo = ["min": progressBarMin, "max": progressBarMax, "increment": progressBarIncr]	// dictionary used by Notification.post (see Apple developer documentation)
	
	
	//	Sequence through the validTimeAndEleArray to calculate the the distance, gain, and speed for all possible legs
	var validTrkptsForStatistics = currentTrack.trkptsList
					.filter({$0.hasValidTimeStamp && $0.hasValidElevation})		//  get only those trackpoints that have a valid elevation and a valid timeStamp
	let validElevationArray = currentTrack.trkptsList.filter({$0.hasValidElevation})
	//print("\(currentTrack.header) : ")
	if validTrkptsForStatistics.count < 2 {										// not enough time and elevation trackpoints
		currentTrack.noValidTimeEle = true
		//print("not enough TimeAndEle")
		if validElevationArray.count >= 2 {										// check if there is enough elevation trackpoints
			validTrkptsForStatistics = validElevationArray
			for i in 0 ... validTrkptsForStatistics.count - 1  {
				guard validTrkptsForStatistics[i].copyToStatisticsStruct("Ele") else { return }
			}

			//print("using validElevationArray")
		} else {
			currentTrack.noValidEle = true
			return																//	early return if there are not enough entries in the ValidTimeAndEleArray
		}
	} else {
		for i in 0 ... validTrkptsForStatistics.count - 1 {
			guard validTrkptsForStatistics[i].copyToStatisticsStruct("EleTime") else { return }
		}
		//print("using validTimeElevationArray")
	}
	
	
	for k in 0 ... (currentTrack.validTrkptsForStatistics.endIndex - 2) {
		
		currentTrack.parseProgress = k

		/*DispatchQueue.main.async {												// update the progress bar.  NOTE: the Notification.post is wrapped and dispatched back to
																				//	the main thread.
																				//  this is required so that all UI updates are done on the main thread.  Eliminated runTime errors found
			
			// 	in the case where gpxDocumentArray has not yet been populated (e.g. parentViewController == nil), then createMileageStats will not attempt to update
			//	the window progress bar
			
			if let pvc = parentViewController {
				NotificationCenter.default.post(name: .updateProgNotification, object: pvc.windowControllers[0].contentViewController as! MainViewController,  userInfo: userInfo)
			}
		} */
		
		for j in k ... (currentTrack.validTrkptsForStatistics.endIndex - 1) {					// sequence through all points between the current one and the last one.  This creates all possible track
																				//	segments (leg) for the current trackpoint
			var tempLegStats = LegStatsStruct()
			
			tempLegStats.gain = (calcGain(currentTrack.validTrkptsForStatistics[j], currentTrack.validTrkptsForStatistics[k]) ?? 0.0)			//	determine true gain over the distance relies only on start/end elevations
			tempLegStats.startIndex = currentTrack.validTrkptsForStatistics[k].index				// store the starting/ending indices for future reference and debug
			tempLegStats.endIndex = currentTrack.validTrkptsForStatistics[j].index				//  NOTE:  the index is the index item in currentTrack.trkptsList, NOT of the subarray
						
			// calculate the ascent and descent properties.  Since a trail will go up/down over a distance we use
						//	the sum of the positive gains/distances/times over all segments within the leg for ascent properties
						//	and, similarly, the sum of the negative gains for descent properties
			let ascentDescentArray = currentTrack.validTrkptsForStatistics[k...j]				// create an array of the the leg in question.  Do this once to eliminate always creating it
																				// as part of the specific statistic calculataion
			//******************************************************************
			//**   have to change to reflect routing (i.e. may not have time) **
			//******************************************************************
			tempLegStats.distance = ascentDescentArray.map({$0.statisticsTrkpt.distance}).reduce(0,+)	// distance only relies on the beginning and end lat/long
			tempLegStats.elapsedTime = ascentDescentArray.map({$0.statisticsTrkpt.elapsedTime}).reduce(0,+)	//	similarly the elapsed time only relies on the beginning/end timeStamps
			// time dependency (lastTimeEleTrkpt)
			tempLegStats.ascent = ascentDescentArray.filter({$0.statisticsTrkpt.gain >= 0}).map({$0.statisticsTrkpt.gain}).reduce(0,+)	// sum all positive gain in the subarray
			tempLegStats.ascentElapsedTime = ascentDescentArray.filter({$0.statisticsTrkpt.gain >= 0}).map({$0.statisticsTrkpt.elapsedTime}).reduce(0,+)
																				// sum all elapsed time for positive gain in the subarray
			tempLegStats.descent = ascentDescentArray.filter({$0.statisticsTrkpt.gain < 0}).map({$0.statisticsTrkpt.gain}).reduce(0,+)	// sum all negative gain in the subarrau
			tempLegStats.descentElapsedTime = ascentDescentArray.filter({$0.statisticsTrkpt.gain < 0}).map({$0.statisticsTrkpt.elapsedTime}).reduce(0,+)			// 	sum all elapsed time for negative gain in the
																				//	subarray
			//******************************************************************
			//******************************************************************
			//******************************************************************
			if (tempLegStats.distance >= metersperMile/8) && (tempLegStats.distance <= metersperMile*(3/16)) {
				overEighthMile.append(tempLegStats)								//	add to the overEighthMile collection
			}
			if (tempLegStats.distance >= metersperMile) {
				overMile.append(tempLegStats)									//	add to the overMile collection
				break															//	break the loop j once the first segment over a mile is found.
			}
			//print("k: \(k), j: \(j), k.latitude \(trkPtList[k].latitude), j.latitude \(trkPtListJ[j].latitude), legValidDistance: \(legValidDistance)")
			if (j % 100) == 0 {
				//print(".", separator: "", terminator: "")						// print a '.' progress indicator when operating from the console
			}
		} // loop j
		
																				// calculate Min/Max statistics for all legs in the overEighthMile collection (there is probably many of these)
		setMinMax(&overEighthMile, &eighthStats.grade, closure: {$0.grade}, loopCount: k, closureNum: 288)
		setMinMax(&overEighthMile, &eighthStats.speed, closure: {$0.trailSpeed}, loopCount: k, closureNum: 289)
		setMinMax(&overEighthMile, &eighthStats.ascent, closure: {$0.ascent}, loopCount: k, closureNum: 290)
		setMinMax(&overEighthMile, &eighthStats.ascentRate, closure: {$0.ascentSpeed}, loopCount: k, closureNum: 291)
		setMinMax(&overEighthMile, &eighthStats.descent, closure: {$0.descent}, loopCount: k, closureNum: 292)
		setMinMax(&overEighthMile, &eighthStats.descentRate, closure: {$0.descentSpeed}, loopCount: k, closureNum: 293)
																				// calculate  Min/Max statistics for all legs in the over mile collection (there is should only be one entry here)
		setMinMax(&overMile, &mileStats.grade, closure: {$0.grade}, loopCount: k, closureNum: 295)
		setMinMax(&overMile, &mileStats.speed, closure: {$0.trailSpeed}, loopCount: k, closureNum: 296)
		setMinMax(&overMile, &mileStats.ascent, closure: {$0.ascent}, loopCount: k, closureNum: 297)
		setMinMax(&overMile, &mileStats.ascentRate, closure: {$0.ascentSpeed}, loopCount: k, closureNum: 298)
		setMinMax(&overMile, &mileStats.descent, closure: {$0.descent}, loopCount: k, closureNum: 299)
		setMinMax(&overMile, &mileStats.descentRate, closure: {$0.descentSpeed}, loopCount: k,closureNum: 300)
		
																				//  caclulate partial sum averages for Rates
		avgAscentRateMile = ((avgAscentRateMile * Double(k)) + overMile.map({$0.ascentSpeed}).reduce(0,max)) / Double(k+1)
		avgDescentRateMile = ((avgDescentRateMile * Double(k)) + overMile.map({$0.descentSpeed}).reduce(0,min)) / Double(k+1)
		if (k % 100) == 0 {						// print progress indicator
			//print("", separator: "", terminator: "\n")							// enter a newline indicator when operation from the console
		}
	} // loop k
	overEighthMile.removeAll()													// clear the array
	overMile.removeAll()														// clear the array
																				// Populare the current track class with all mileage stats
	currentTrack.trackSummary.numberOfDatapoints = currentTrack.trkptsList.count
	currentTrack.trackSummary.eighthMileStats = eighthStats
	currentTrack.trackSummary.mileStats = mileStats
	
	currentTrack.trackSummary.maxGradeMile = currentTrack.trackSummary.mileStats.grade.max.statData
	currentTrack.trackSummary.maxSpeedMile = currentTrack.trackSummary.mileStats.speed.max.statData
	currentTrack.trackSummary.maxAscentMile = currentTrack.trackSummary.mileStats.ascent.max.statData
	currentTrack.trackSummary.avgAscentRateMile = avgAscentRateMile
	currentTrack.trackSummary.maxAscentRateMile = currentTrack.trackSummary.mileStats.ascentRate.max.statData
	currentTrack.trackSummary.maxDescentMile = currentTrack.trackSummary.mileStats.descent.max.statData
	currentTrack.trackSummary.avgDescentRateMile = avgDescentRateMile
	currentTrack.trackSummary.maxDescentRateMile = currentTrack.trackSummary.mileStats.descentRate.max.statData
	
	return
}
	
//**************************



class parseGPXXML: NSObject, XMLParserDelegate, ObservableObject {
	

	
	
	var numCalls : Int								// Dictionary that contains the overall summary stats of the track
	var currentTrackIndex : Int
	var currentTrkptIndex : Int
	var lastTrkptIndex	: Int
	var lastValidTrkptElevationIndex : Int			// The index of the most recent trackpoint to have a valid elevation property
	var lastValidTrkptTimestampIndex : Int			// The index of the most recent trackpoint to have a valid timestamp/
	var lastValidEleAndTimeIndex : Int				// The index of the most recent trackpoint to have BOTH a valid elevation & valid timestamp
	var fcShouldExpect : String
	var elementsBeingProcessed = ElementProcessingState(value:false)
	@Published var currentTrack = Track()
	var allTracks = [Track]()
	var currentTrkpt = Trkpt()
	//*** var parentViewController: MainViewController		// this causes a Runtime warning about this not being in the Main Thread.  Not sure what
													//	to do about it yet
	var parseURL: URL
	//*** var gpxDocumentArray = [Document]()											// holds the documents created when a track is found
	var gpxTrackArray = [Track]()					// changed from Document type to Track type to reflect change to SwiftUI
	var withStats : Bool
	var parseStarted : Bool = false
	var parseEnded : Bool = false
	
	
	
	override init() {
		self.numCalls = 0
		self.fcShouldExpect = nullString
		self.currentTrackIndex = 0
		self.currentTrkptIndex = 0
		self.lastTrkptIndex = -1
		self.lastValidTrkptElevationIndex = -1
		self.lastValidTrkptTimestampIndex = -1
		self.lastValidEleAndTimeIndex = -1
		//*** self.parentViewController = MainViewController()
		self.parseURL = URL(string: "blah")!
		self.withStats = true
		super.init()
	}
	
	//	func parseURL( gpxURL: URL, parentViewController: MainViewController)
	func parseURL( gpxURL: URL, withStats: Bool) -> Int {										// returns number of tracks in a URL
		var returnValue: Int
		var parserSuccess: Bool = false
			
		self.withStats = withStats
		self.parseURL = gpxURL
		let gpxParser = XMLParser(contentsOf: gpxURL)!
		gpxParser.delegate = self
		gpxParser.shouldReportNamespacePrefixes = true
		gpxParser.shouldProcessNamespaces = true
		
		//print("parseQueue: parse started for \(gpxURL.lastPathComponent)")
		parserSuccess = gpxParser.parse()
		if !parserSuccess {
			// Parser Error
			//print("XML parsing failed at \(gpxParser.lineNumber):\(gpxParser.columnNumber) \nDebug Description: \(gpxParser.debugDescription)")
			returnValue = 0
		} else {
			//print("parseQueue: parse ended for \(gpxURL.lastPathComponent)")
			//print("self.allTracks.count = \(self.allTracks.count)")
			returnValue = self.allTracks.count
		}
			
		
		return returnValue
	}
	
	private func processElement(elementName: String,
								qName: String?,
								attributes: [String:String])  {					// processElement is only called with 'other' elementNames
		
		if  elementsBeingProcessed.trk &&
			!elementsBeingProcessed.trkSeg &&
			garminSummaryStats.contains(elementName) {
				currentTrack.garminSummaryStats[elementName] = "waitingforfoundCharacters"		//  Should be in the Summary area of the xml (i.e. trk && !trkSeg
				fcShouldExpect = elementName
				//print(elementName)
		}
		
		if elementsBeingProcessed.trk &&
			elementsBeingProcessed.trkSeg &&
			elementsBeingProcessed.trkpt {
																				// get the latitude, ongitude, time, and elevation.  The closure are simply for safety.
																				//	the only elements currently tracks are trackpoint, routepoint, elevation, and time
																				//	These values should always be available unless the garmin gpx is not properly formed
			
			switch elementName {
				//	The handling of trackpoints and route points is different that elevation and time.  In the garmin .gpx format the latitude and longitude are
				// 		labeled with 'lat =' and 'long ='
			case "trkpt", "rtept":
				

				if let tempVar = attributes["lat"] {
					currentTrkpt.latitude = Double(tempVar)!					// Can safely forceunwrap because if there is a latitude garmin will ensure it is properly formed
				}
				if let tempVar = attributes["lon"] {
					currentTrkpt.longitude = Double(tempVar)!					// safe to unwrap for same reason latitude is safe
				}
			case "ele":
				fcShouldExpect = elementName
			case "time":
				fcShouldExpect = elementName
			default :
				break															// do nothing
			}
		}
	}
	
	
	
	func parserDidStartDocument(_ parser: XMLParser) {
		print("xml parsing started: \(parseURL.lastPathComponent)")
		parseStarted.toggle()
	}
	
	func parserDidEndDocument(_ parser: XMLParser) {

		print("xml parsing documentEnd:\(parseURL.lastPathComponent)")
		parseEnded.toggle()
	}
	
	//	Process Starting Elements.  Those with a < elementName> XML tag  ********************************************
	func parser(_ parser: XMLParser,
				didStartElement elementName: String,
				namespaceURI: String?,
				qualifiedName qName: String?,
				attributes: [String : String])   {
		numCalls += 1										// Keep track of how many times didStartElement has been called
		switch elementName {
			case "trk", "rte" :		// a <trk> tag currently frames a single track recording.  It is generally composed of one or more
								// 	<trkseg> tags (although to date I have only seen a single <trkseg>.
				
					// to implement early window creation I need to find a way to signal the ?mainViewController? to create a
					// document at this time
				elementsBeingProcessed.trk = true								// set track processing flag
				currentTrackIndex += 1											// increment the local track ID
				currentTrack.trkIndex = currentTrackIndex								// set the current track's id
				currentTrack.trackURLString = self.parseURL.absoluteString		// set the current track's URL to the URL passed in to init
				currentTrkptIndex = -1											// new track starts a new sequence of trackpoints
				lastValidTrkptTimestampIndex = -1
				lastValidTrkptElevationIndex = -1
				lastValidEleAndTimeIndex = -1
				lastTrkptIndex = -1
					
			case "trkseg" :		// a <trkseg> tag currently frames a set of <trkpt> tags.  To date, I have only seen a single <trkseg>
								//	with no extra data provided unique to the <trkseg>.  Therefore, do nothing with this tag
				elementsBeingProcessed.trkSeg = true							// set track segment processing flag
			
			case "trkpt", "rtept":		// a <trkpt> tag defines a specific waypoint in the track.  It is composed of string for latitude "lat",
								//	and longitude "lon".  There will be two followup optional tags <ele> for elevation and <time> for a date/time stamp
								// 	Since <ele> and <time> are not StartElements they will generate "FoundCharacters" events and processed in
								//	that function
				elementsBeingProcessed.trkpt = true								// set track point processing flag
				
				currentTrkptIndex += 1											// increment the trackpoint index being worked on
				currentTrkpt.index = currentTrkptIndex							// set the trackpoint index property
				currentTrkpt.hasValidElevation = false							// with a new trackpoint clear the valid elevation flag
				currentTrkpt.hasValidElevation = false							// and the valid timestamp flag
				processElement(elementName: elementName, qName: qName, attributes: attributes)
			
			case "ele" :		// "ele" tags a piece of elevation data
				elementsBeingProcessed.other = true
				processElement(elementName: elementName, qName: qName, attributes: attributes)
			case "time" :		// "time" tags a timeStamp
				elementsBeingProcessed.other = true
				processElement(elementName: elementName, qName: qName, attributes: attributes)
			default :			// at this point all other Elements are passed to processElement for unique handling.  In general, unique
								// 	handling will be to determined by the "elementsBeingProcessed" state.
				elementsBeingProcessed.other = true
				processElement(elementName: elementName, qName: qName, attributes: attributes)
		}
		//print("\n\ndidStartElement Calls > \(numCalls)")
		//print("didStartElement: \(elementName)")
		//print("namespaceURI: \(namespaceURI!)")
		//print("qualifiedName: \(qName!)")
		//for (key, value) in attributes {
			//let x = attributes[key]
		//	print("[\(key)::\n\t\(value)]")
		//}
		
		
	}
	
	func populateTrkptStructures() {											// Once all tags associated with the active trackpoint have been parsed this method
																				// 	will populate the full trackpoint structure
		
		
		if currentTrkpt.index > 0 {
			//	populate lastTrkpt structure (index, distance)
			currentTrkpt.lastTrkpt.lastValidIndex = currentTrkpt.index - 1			//	the last trackpoint is the previous trackpoint in the current track
			currentTrkpt.lastTrkpt.distance = calcDistance(currentTrkpt,
															currentTrack.trkptsList[currentTrkpt.lastTrkpt.lastValidIndex])
		}
		if lastValidTrkptTimestampIndex >= 0 {
			// Calculate the distance between the current trackpoint and the previous one
			//	populate lastDistTrkpt structure (index, distance, elapsedTime... travelSpeed is a get-only property)
			currentTrkpt.lastTimeDistTrkpt.lastValidIndex = lastValidTrkptTimestampIndex
			currentTrkpt.lastTimeDistTrkpt.distance = calcDistance(currentTrkpt,
																   currentTrack.trkptsList[currentTrkpt.lastTimeDistTrkpt.lastValidIndex])
			currentTrkpt.lastTimeDistTrkpt.elapsedTime = calcElapsedTime(currentTrkpt,
																	 currentTrack.trkptsList[currentTrkpt.lastTimeDistTrkpt.lastValidIndex])
																			// trailSpeed is a get-only property
		}
		if lastValidEleAndTimeIndex >= 0 {
			//	populate lastTimeEleTrkpt structure (index, gain, elapsedtime...  gainSpeed is a get-only property
			currentTrkpt.lastTimeEleTrkpt.lastValidIndex = lastValidEleAndTimeIndex
		
			if let elevationGain = calcGain(currentTrkpt,
											currentTrack.trkptsList[currentTrkpt.lastTimeEleTrkpt.lastValidIndex]) {
				currentTrkpt.lastTimeEleTrkpt.gain = elevationGain
			}
			currentTrkpt.lastTimeEleTrkpt.elapsedTime = calcElapsedTime(currentTrkpt,
																	 currentTrack.trkptsList[currentTrkpt.lastTimeEleTrkpt.lastValidIndex])
			currentTrkpt.lastTimeEleTrkpt.distance = calcDistance(currentTrkpt, currentTrack.trkptsList[currentTrkpt.lastTimeEleTrkpt.lastValidIndex])
		}
		
		if lastValidTrkptElevationIndex >= 0 {
			currentTrkpt.lastEleTrkpt.lastValidIndex = lastValidTrkptElevationIndex
			currentTrkpt.lastEleTrkpt.distance = calcDistance(currentTrkpt, currentTrack.trkptsList[currentTrkpt.lastEleTrkpt.lastValidIndex])
			if let elevationGain = calcGain(currentTrkpt, currentTrack.trkptsList[currentTrkpt.lastEleTrkpt.lastValidIndex]) {
				currentTrkpt.lastEleTrkpt.gain = elevationGain
			}
			
		}
		
		
		switch (currentTrkpt.hasValidElevation, currentTrkpt.hasValidTimeStamp) {
		case (false, true) :
			//print("have no elevation, but have timestamp")
			lastValidTrkptTimestampIndex = currentTrkpt.index
		case (true, false) :
			//print("have elevation, but no timestamp")
			lastValidTrkptElevationIndex = currentTrkpt.index
		case (true, true) :
			//print("have both elevation & timestamp")
			lastValidTrkptElevationIndex = currentTrkpt.index
			lastValidTrkptTimestampIndex = currentTrkpt.index
			lastValidEleAndTimeIndex = currentTrkpt.index
		default:
			//print("have no elevation AND no timestamp")
			break																// legal way to 'do nothing'
		}
	}
	
	
	
		// Process information that is not captured by a "xxx=" label (e.g. lat= or lon=.  In current (11/6/2019) version this is only capturing elevation (ele) and/timestamp (time)
	func parser(_ parser: XMLParser, foundCharacters: String) {
		if elementsBeingProcessed.trk && !elementsBeingProcessed.trkSeg && fcShouldExpect != nullString {
			// A /<trk> tag has been found but not a /<trkseg> tag, meaning we are in the header portion of the track information.  If I've found
			// 	a "name" tag then create a document and a view controller  to display and hold the track information.  This insures I have the
			//	necessary UI objects ready.
			
			currentTrack.garminSummaryStats[fcShouldExpect] = foundCharacters
			if fcShouldExpect == "name" {
				
				// interim step to open tabView when "name" of track is found
				self.currentTrack.header = foundCharacters						// header gets the "name" of the treack
				self.allTracks.append(self.currentTrack)						// addend that to allTracks.  Need a way to publish to the View
				
				//***
				//	This section of code is intende to create another tabbed window to hold newly parsed track summaries.  Dispatch is
				//		used here to create the window on the main thread to allow for progress indicators to be displayed.  Creating
				//		the window without Dispatch created a runtime warning/error related to changing the User Interface outside the
				//		main thread
				/* DispatchQueue.main.async {
					if MainViewController.firstGPXParse {
						let gpxSummaryDocument = self.parentViewController.view.window?.windowController?.document as! Document
						let viewController = gpxSummaryDocument.windowControllers[0].contentViewController as! MainViewController
						viewController.textView.string = "Working ..."										// output the results to the view
						viewController.view.window?.title = foundCharacters
						//print("appending gpxSummaryDocument \(gpxSummaryDocument), firstparse", self.parentViewController.isViewLoaded)
						self.gpxDocumentArray.append(gpxSummaryDocument)
						MainViewController.firstGPXParse = false
					} else {
						do {
							let gpxSummaryDocument = try documentController.openUntitledDocumentAndDisplay(true) as! Document
							let viewController = gpxSummaryDocument.windowControllers[0].contentViewController as! MainViewController
							viewController.textView.string = "Working ..."										// output the results to the view
							viewController.view.window?.title = foundCharacters
							print("appending gpxSummaryDocument \(gpxSummaryDocument), not firstparse")
							self.gpxDocumentArray.append(gpxSummaryDocument)
						} catch let error as NSError {						// if the documentController doesn't have a window or document the abort
							self.parentViewController.doHikingDbAlert(message: "open failed \(error), file: \(self.parseURL.absoluteString)")
						//fatalError("open failed \(error), file: \(filesArray[i])")
						}
					}
				}*/
				//***
			}
			fcShouldExpect = nullString
		}
		
		if elementsBeingProcessed.trk &&
			elementsBeingProcessed.trkSeg &&
			elementsBeingProcessed.trkpt {
			switch fcShouldExpect {
			case "ele" :
				if let tmpInt = Double(foundCharacters) {
					currentTrkpt.elevation = tmpInt
				}
			case "time":
				// Set date format
				let dateFmt = DateFormatter()
				dateFmt.timeZone = TimeZone(abbreviation: "GMT")
				dateFmt.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss'Z'"
				let date =  dateFmt.date(from:foundCharacters)
				if let tmpdate = date {
					currentTrkpt.timeStamp = tmpdate
				} else {
					break
					//print("unexpected foundCharacters in 'time' '\(foundCharacters)'")
				}
			default :
				
				//print(" unexpected characters in '\(fcShouldExpect)': '\(foundCharacters)': file: \(parseURL.lastPathComponent)")
				break
			}
		}
		//print("foundCharacters: '\(foundCharacters)'")
	}
	
		// Process End Elements.  Those with a < /elementName> XML tag  ************************************************
	func parser(_ parser: XMLParser,
				didEndElement elementName: String,
				namespaceURI: String?,
				qualifiedName qName: String?) {
		switch elementName {
		case "trk", "rte" :			// Encounterd the </trk> tag indicating end of the track.  Move all the various information gathered into
								//	the currentTrack structure and change the state of elementsBeingProcessed.
					// This is also the time to generate all the tracks vital statistics
						
			if let tempname = currentTrack.garminSummaryStats["name"] {
				// put the track name into the track header
				currentTrack.header = tempname
				if tempname.contains("\n") {
					currentTrack.header = " "
				}
			}
			
			if withStats {
				calculateTrkProperties(&currentTrack)								//  calculate all the track properties that do not rely on specific mileage informaton
				createMileageStats(&self.currentTrack)								//  create all the track properties that require information regarding mileage.
			}
					//	in the case of near empty or very small .gpx files gpxDocumentArray may not have yet been populated yet from the earlier dispatchQueue.
					//	In that case createMileageStats will not attempt to update the window progress bar add the current track to the all tracks array
			if self.allTracks.count != 0 {
				self.allTracks[self.allTracks.endIndex - 1] = self.currentTrack
			} else {
				self.allTracks[0] = self.currentTrack
			}//	add the current track to the all tracks array
			currentTrack.clean()												// 	clean up and empty the current track variable
			elementsBeingProcessed.trk = false									// 	since we're done, clear processing flag
		case "trkseg" :
			elementsBeingProcessed.trkSeg = false
		case "trkpt", "rtept" :
			//  when the trkpt/rtept end tag is processed the currentTrkpt can only be guaranteed to have .index, .latitude, and .longitude populated
			//		it may have .elevation and .timeStamp populated as well.  It is now time to populate the remainder of the trackpoint structure
			//	To fully populate the trackpoint I need to know the last valid elevation trackpoint index and the last valid distance trackpoint index.
			//	The question is "where to I set those variables?
			//print("\(Thread.current)")
			populateTrkptStructures()
			updateLastValidIndexPointers()
			currentTrack.trkptsList.append(currentTrkpt)						// 	add the current trackpoint to the track point lis
			currentTrkpt = .init()												//	clean up and empty the current track point variable
			elementsBeingProcessed.trkpt = false
		case "ele" :															// a </ele> tag has been found, now post process the appropriate elevation properties, if any
			currentTrkpt.hasValidElevation = true								// set the valid elevation flag to let the end trackpoint </trkpt> process know there was a
																				//		valid elevation found
			elementsBeingProcessed.other = false
		case "time" :															// a </time> tag has been found, now post process the appropriate timestamp properties, if any
			currentTrkpt.hasValidTimeStamp = true											// set the valid timestamp flag to let the end trackpoint prodess know there was a valide timestamp
			elementsBeingProcessed.other = false
		default :
			elementsBeingProcessed.other = false
			// if the elementName is "name" then I know I have a track name and could populate the document title with the name of the track
		}
	}
	
	func updateLastValidIndexPointers () {
		
	}
	
	
}

class parseController:  ObservableObject {
	
	
	
	@Published var parsedTracks : [Track] = []
	@Published var numberOfTracks : Int = 0
	
		
	
	func parseGpxFileList (_ filesArray: [URL]) -> Bool {					// filesArray contains a list of all URLs requested to be parsed.
		let myparsegpxxml = parseGPXXML()
		// parseGpxFileList currently always returns true
		for i in 0 ... filesArray.count-1 {
			
				//let myparsegpxxml = parseGPXXML()
				let parseNumTracks = myparsegpxxml.parseURL(gpxURL: filesArray[i], withStats: false)
				self.numberOfTracks += parseNumTracks
				if parseNumTracks != 0 {
					self.parsedTracks += myparsegpxxml.allTracks
			}
				
			}
		//print("firstParse number of tracks - \(self.numberOfTracks)")
		for i in (0 ..< self.numberOfTracks) {
			//print("header[\(i)] = \(self.parsedTracks[i].header)")
		}
		
		for i in 0 ... filesArray.count-1 {
			let parseQueue = DispatchQueue(label: filesArray[i].lastPathComponent, attributes: .concurrent)
			parseQueue.async {
				let myparsegpxxml = parseGPXXML()
				let parseNumTracks = myparsegpxxml.parseURL(gpxURL: filesArray[i], withStats: true)
				DispatchQueue.main.async {
					if parseNumTracks != 0 {
						for track in (0 ... parseNumTracks - 1) {
							if let parseHeaderIndex = self.parsedTracks.firstIndex(where: {$0.header == myparsegpxxml.allTracks[track].header}) {
								self.parsedTracks[parseHeaderIndex] = myparsegpxxml.allTracks[track]
							}
						}
						//self.parsedTracks += myparsegpxxml.allTracks
					}
				}
			}
		}
		return true
	}
	
	func parseSingleFile (_ file: URL) -> Bool {
		let myparsegpxxml = parseGPXXML()
		let parseNumTracks = myparsegpxxml.parseURL(gpxURL: file, withStats: true)
		if parseNumTracks != 0 {
			self.parsedTracks += myparsegpxxml.allTracks
		}
		return true
	}
}



