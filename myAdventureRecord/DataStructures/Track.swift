//
//  Track.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/6/20.
//

import Foundation

struct Track: Codable, Hashable, Identifiable{																	// the structure of a track.  This needs to be modified to create an init as well as some logging/print methods
	
	struct TrkSummaryStats: Codable, Hashable {
		struct  ElevationStats : Codable, Hashable {
			struct Max: Codable, Hashable{
				var elevation: Double = 0.0
				var index: Int = 0
			}
			
			struct Min: Codable, Hashable {
				var elevation: Double = Double.greatestFiniteMagnitude
				var index: Int = 0
			}
			var max = Max()
			var min = Min()
		}
		
		var numberOfDatapoints: Int = 0
		var distance : Double = 0.0
		var startElevation: Double = 0.0
		
		var elevationStats = ElevationStats()
		var startTime: Date?
		var endTime: Date?
		var duration: Double = 0.0
		var totalAscent: Double = 0.0
		var totalAscentTime: Double = 0.0
		var totalDescent: Double = 0.0
		var totalDescentTime: Double = 0.0
		var netAscent: Double = 0.0
		var avgDescentRate = 0.0
		var avgSpeed = 0.0
		var avgAscentRate = 0.0
		
		
		var eighthMileStats = MileageStats()
		var mileStats = MileageStats()
		
		
		
		var maxGradeEighth = 0.0
		var maxGradeMile = 0.0
		var maxSpeedMile = 0.0

		var maxAscentMile = 0.0
		var avgAscentRateMile = 0.0
		var maxAscentRateMile = 0.0
		

		var maxDescentMile = 0.0
		var avgDescentRateMile = 0.0
		var maxDescentRateMile = 0.0
		
	}
	
	var id = UUID()
	var trkIndex: Int								// need to keep around after first parse
	var header: String					// need to keep around after first parse
	var parseProgress : Int				// needed for observation of how much of the statistics creation is complete (for ProgressView)
	var garminSummaryStats = [String: String]()			// need to keep around after first parse
	var trackSummary: TrkSummaryStats				// need to keep around after first parse
	var trackURLString : String								// need to keep around after first parse
	var trackComment : String
	var trkptsList = [Trkpt]()
	var noValidTimeEle : Bool
	var noValidEle : Bool
	var validTrkptsForStatistics: [Trkpt]
	
	init () {
		self.trkIndex = 0
		self.header = "init - header set null" //nullString
		self.parseProgress = 0
		self.trkptsList.removeAll()
		self.trackSummary = TrkSummaryStats()
		self.trackURLString = nullString
		self.trackComment = nullString
		self.noValidTimeEle	= false
		self.noValidEle = false
		self.validTrkptsForStatistics = []
	}
	
	mutating func clean() {
		trkIndex = 0
		header = nullString
		garminSummaryStats = [:]
		trkptsList.removeAll()
	}
	
	func exportCSVLine(_ header: Bool) -> String {
		var csvString: String = nullString
		
		if header {
			csvString = "row, header, trkptsList.count, URL, date, startTime, endTime, duration, distance, startElevation, maxElevation, minElevation, totalAscent, totalDescent, netAscent, avgSpeed, "
			csvString.append(String("1/8gradeMax, 1/8gradeMin, mileGradeMax, mileGradeMin, 1/8speedMax, 1/8speedMin, mileSpeedMax, mileSpeedMin, 1/8ascentMax, 1/8ascentMin, mileAscentMax, mileAscentMin, "))
			csvString.append(String("1/8ascentRateMax, 1/8ascentRateMin, mileAscentRateMax, mileAscentRateMin, totalAscent, 1/8descentMax, 1/8descentMin, mileDescentMax, mileDescentMin, totalDescent, "))
			csvString.append(String("1/8descentRateMax, 1/8descentRateMin, mileDescentRateMax, mileDescentRateMin, avgDescentRate, "))
			for (key,_) in self.garminSummaryStats {
				csvString.append(String(format: "%@, ", key))
			}
			csvString.append(String("\n"))
			return csvString
		}
		csvString.append(String(format: "\(self.header), \(self.trackSummary.numberOfDatapoints), "))						// row is written in calling method, header, trackptlist.cout
		csvString.append(String(format: "%@, ", self.trackURLString.removingPercentEncoding ?? ""))			// URL
		if let theTime = self.trackSummary.startTime {
			let dateFmt = DateFormatter()
			dateFmt.timeZone = TimeZone.current
			dateFmt.dateFormat =  "MM/dd/yyyy"
			csvString.append(String(format: "\(dateFmt.string(from: theTime)), "))							// date
			dateFmt.dateFormat = "HH:mm"
			csvString.append("\(dateFmt.string(from: theTime)), ")											// startTime
		}
		if let theTime = self.trackSummary.endTime {
			let dateFmt = DateFormatter()
			dateFmt.timeZone = TimeZone.current
			dateFmt.dateFormat = "HH:mm"
			csvString.append("\(dateFmt.string(from: theTime)), ")											// endTime
		}
		csvString.append(String(format: " %5.2f, ", self.trackSummary.duration / secondsperHour))			// duration in hr
		
		csvString.append( String(format: "%3.3f, ", self.trackSummary.distance/metersperMile))				// distance in miles
		
		csvString.append(String(format: " %5.2f, ", self.trackSummary.startElevation*feetperMeter ))		// startelevation in ft
		csvString.append(String(format: "%5.2f, ", self.trackSummary.elevationStats.max.elevation*feetperMeter))	// maxelevation in ft
		csvString.append(String(format: "%5.2f, ", self.trackSummary.elevationStats.min.elevation*feetperMeter))	// minelevation in ft
		
		csvString.append(String(format: " %5.2f, ", self.trackSummary.totalAscent*feetperMeter))			// total ascent in ft
		csvString.append(String(format: "%5.2f, ", self.trackSummary.totalDescent*feetperMeter))			// total descent in ft
		csvString.append(String(format: "%5.2f, ", self.trackSummary.netAscent*feetperMeter))				// netascent in ft
		csvString.append(String(format: "%5.2f, ", self.trackSummary.avgSpeed/metersperMile*secondsperHour))// avgspeed in miles/hour
		
		
		
		//  Mileage based stats
		guard (!self.noValidTimeEle || !self.noValidEle) else {
			csvString.append(String(format: "\n"))
			return csvString
		}
		// Grade *******
		csvString.append(String(format: "%3.2f%%, ", self.trackSummary.eighthMileStats.grade.max.boundedStatData*100))	// 1/8grademax
			
		csvString.append(String(format: "%3.2f%%, ", self.trackSummary.eighthMileStats.grade.min.boundedStatData*100))	// 1/8grademin
		csvString.append(String(format: "%3.2f%%, ", self.trackSummary.mileStats.grade.max.boundedStatData*100))		// milegrademax
		csvString.append(String(format: "%3.2f%%, ", self.trackSummary.mileStats.grade.min.boundedStatData*100))		// milegrademin
		
		// Speed ******
		csvString.append(String(format: "%3.2f, ", self.trackSummary.eighthMileStats.speed.max.boundedStatData*(secondsperHour/metersperMile)))	// 1/8speedmax
		
		csvString.append(String(format: "%3.2f, ", self.trackSummary.eighthMileStats.speed.min.boundedStatData*(secondsperHour/metersperMile))) // 1/8speed min
		csvString.append(String(format: "%3.2f, ", self.trackSummary.mileStats.speed.max.boundedStatData*(secondsperHour/metersperMile)))		// milespeedmax
		csvString.append(String(format: "%3.2f, ", self.trackSummary.mileStats.speed.min.boundedStatData*(secondsperHour/metersperMile)))		// milespeedmin
		
		// Ascent ******
		csvString.append(String(format: " %5.2f, ", self.trackSummary.eighthMileStats.ascent.max.boundedStatData))		// 1/8ascentmax
		csvString.append(String(format: "%5.2f, ", self.trackSummary.eighthMileStats.ascent.min.boundedStatData))		// 1/8ascentmin
		csvString.append(String(format: "%5.2f, ", self.trackSummary.mileStats.ascent.max.boundedStatData))				// mileascentmax
		csvString.append(String(format: "%5.2f, ", self.trackSummary.mileStats.ascent.min.boundedStatData))				// mileascentmin
		
		//  AscentRate ******
		csvString.append(String(format: "%5.2f, ",
								   (self.trackSummary.eighthMileStats.ascentRate.max.boundedStatData)*(feetperMeter*secondsperHour)))		// 1/8ascentratemax
		csvString.append(String(format: "%5.2f, ",
								   self.trackSummary.eighthMileStats.ascentRate.min.boundedStatData*(feetperMeter*secondsperHour)))			// 1/8ascentratemin
		csvString.append(String(format: "%5.2f, ",(self.trackSummary.mileStats.ascentRate.max.boundedStatData)*(feetperMeter*secondsperHour)))	// mileascentratemax
		csvString.append(String(format: "%5.2f, ",self.trackSummary.mileStats.ascentRate.min.boundedStatData*(feetperMeter*secondsperHour)))	// mileascentratemin
		
		csvString.append(String(format: "%5.2f, ",(self.trackSummary.totalAscent*feetperMeter) /  (trackSummary.totalAscentTime == 0 ? 0 : trackSummary.totalAscentTime / secondsperHour)))																								// totalascentRate
		// Descent ******  because descents are negative numbers max and min are reversed
		//						***  bugs me that I do it here and not by swapping where I
		//								determine max/min, but there is something goofy there
		csvString.append(String(format: "%5.2f, ", self.trackSummary.eighthMileStats.descent.min.boundedStatData*feetperMeter))	// 1/8descentmax
		csvString.append(String(format: "%5.2f, ", self.trackSummary.eighthMileStats.descent.max.boundedStatData*feetperMeter))	// 1/8descentmin
		csvString.append(String(format: "%5.2f, ", self.trackSummary.mileStats.descent.min.boundedStatData*feetperMeter))		// miledescentmax
		csvString.append(String(format: "%5.2f, ", self.trackSummary.mileStats.descent.max.boundedStatData*feetperMeter))		// miledescentmin
		// DescentRate ******  because descents are negative numbers max and min are reversed
		//						***  bugs me that I do it here and not by swapping where I
		//								determine max/min, but there is something goofy there
		csvString.append(String(format: "%5.2f, ", (self.trackSummary.eighthMileStats.descentRate.min.boundedStatData)*(feetperMeter*secondsperHour)))	// 1/8descentratemax
		csvString.append(String(format: "%5.2f, ", (self.trackSummary.eighthMileStats.descentRate.max.boundedStatData)*(feetperMeter*secondsperHour)))	// 1/8descentratemin
		csvString.append(String(format: "%5.2f, ", (self.trackSummary.mileStats.descentRate.min.boundedStatData)*(feetperMeter*secondsperHour)))		// miledescentratemax
		csvString.append(String(format: "%5.2f, ", (self.trackSummary.mileStats.descentRate.max.boundedStatData)*(feetperMeter*secondsperHour)))		// miledescentratemin
		csvString.append(String(format: "%5.2f, ", (self.trackSummary.avgDescentRateMile)*(feetperMeter*secondsperHour)))
		csvString.append(String(format: "%5.2f. ", (self.trackSummary.totalDescent*feetperMeter) / (trackSummary.totalDescentTime == 0 ? 0 : trackSummary.totalDescentTime / secondsperHour)))																								// totaldescentrate
		
		for (_,value) in self.garminSummaryStats {
			csvString.append(String(format: "%@, ", value))
		}
		
		csvString.append(String(format: "\n"))
		return csvString
	}
	
	func print(_ noConsole : Bool = false) -> String {
		var localDistance: Double = 0
		var outputString: String = nullString
		outputString.append(String(format: "\nTrack Statistics for \(self.header), \(self.trackSummary.numberOfDatapoints) data points\n"))
		outputString.append(String(format: "\tTrack URL : %@\n", self.trackURLString.removingPercentEncoding ?? ""))
		outputString.append(String(format: "\nTrack Summary Stats\n"))
		if !self.noValidTimeEle {
			if let theTime = self.trackSummary.startTime {
				let dateFmt = DateFormatter()
				dateFmt.timeZone = TimeZone.current
				dateFmt.dateFormat =  "MMM dd, yyyy"
				outputString.append(String(format: " Date of Hike - \(dateFmt.string(from: theTime))\n"))
				dateFmt.dateFormat = "hh:mm a"
				outputString.append(" Start Time - \(dateFmt.string(from: theTime)) \(TimeZone.current.identifier)\n")
			}
			if let theTime = self.trackSummary.endTime {
				let dateFmt = DateFormatter()
				dateFmt.timeZone = TimeZone.current
				dateFmt.dateFormat = "hh:mm a"
				outputString.append(" End Time - \(dateFmt.string(from: theTime))\n")
			}
			let hoursDuration = Int(self.trackSummary.duration / secondsperHour)
			let minutesDuration = Int((Double(self.trackSummary.duration/secondsperHour) - Double(hoursDuration))*60.0)
			outputString.append(String(format: " Total Duration - %3d:%2d hours:min\n", hoursDuration, minutesDuration))
		}
		
		outputString.append( String(format: " Length %3.3f miles ", self.trackSummary.distance/metersperMile))
		if let garminDistance = self.garminSummaryStats["Distance"] {
			localDistance = Double(garminDistance)!
			outputString.append( String(format: ":  Garmin Length %3.3f miles\n", Double(garminDistance)!/metersperMile))
		} else {
			outputString.append("\n")
		}
		
		outputString.append(String(format: " Start Elevation - %5.2f feet\n", self.trackSummary.startElevation*feetperMeter ))
		outputString.append(
			String(format: " Maximum Elevation - %5.2f feet [%4d]\n", self.trackSummary.elevationStats.max.elevation*feetperMeter,
																		self.trackSummary.elevationStats.max.index))
		outputString.append(String(format: " Minimum Elevation - %5.2f feet [%4d]\n", self.trackSummary.elevationStats.min.elevation*feetperMeter,
																		self.trackSummary.elevationStats.min.index))
		
		outputString.append(String(format: " Total Ascent - %5.2f feet\n", self.trackSummary.totalAscent*feetperMeter))
		outputString.append(String(format: " Total Descent - %5.2f feet\n", self.trackSummary.totalDescent*feetperMeter))
		outputString.append(String(format: " Net Ascent - %5.2f feet\n", self.trackSummary.netAscent*feetperMeter))
		
		if !noValidTimeEle {
		
			outputString.append(String(format: " Average Speed - %5.2f mph : ", self.trackSummary.avgSpeed/metersperMile*secondsperHour))
			if let garminSpeed = self.garminSummaryStats["TotalElapsedTime"] {
				outputString.append(String(format: " Garmin Average Speed %5.2f mph\n", localDistance/Double(garminSpeed)!*(secondsperHour/metersperMile)))
			} else {
				outputString.append("\n")
			}
		}
		
		
		//  Mileage based stats
		guard !self.noValidTimeEle || !self.noValidEle else { return outputString }	// the gpx contained neither a valid
									// set of time and elevation points, nor a set of valid elevation points, so
									// return with the outputstring as constructed (i.e. without mileage stats)
		outputString.append(String(format: "\nTrack Mileage Stats\n"))
		
		// Grade *******
		outputString.append(String(format: "\tGrade\n"))
		outputString.append(String(format: "\t\tMaximum (1/8) - %3.2f%% [%4d,%4d]\n", self.trackSummary.eighthMileStats.grade.max.boundedStatData*100,
									self.trackSummary.eighthMileStats.grade.max.startIndex,
									self.trackSummary.eighthMileStats.grade.max.endIndex))
			
		outputString.append(String(format: "\t\tMinimum (1/8) - %3.2f%% [%4d,%4d]\n", self.trackSummary.eighthMileStats.grade.min.boundedStatData*100,
									self.trackSummary.eighthMileStats.grade.min.startIndex,
									self.trackSummary.eighthMileStats.grade.min.endIndex))
		
		outputString.append(String(format: "\t\tMaximum (mile) - %3.2f%% [%4d,%4d]\n", self.trackSummary.mileStats.grade.max.boundedStatData*100,
									self.trackSummary.mileStats.grade.max.startIndex,
									self.trackSummary.mileStats.grade.max.endIndex))
		
		outputString.append(String(format: "\t\tMinimum (mile) - %3.2f%% [%4d,%4d]\n", self.trackSummary.mileStats.grade.min.boundedStatData*100,
								   self.trackSummary.mileStats.grade.min.startIndex,
								   self.trackSummary.mileStats.grade.min.endIndex))
		
		// Speed ******
		if !self.noValidTimeEle {		// if there is no valid time and elevation stats then there can be no speed
										//	calculation, so skip
										
			outputString.append(String(format: "\tSpeed\n"))
			outputString.append(String(format: "\t\tMaximum (1/8) - %3.2f mph [%4d,%4d]\n", self.trackSummary.eighthMileStats.speed.max.boundedStatData*(secondsperHour/metersperMile),
								   self.trackSummary.eighthMileStats.speed.max.startIndex,
								   self.trackSummary.eighthMileStats.speed.max.endIndex))
		
			outputString.append(String(format: "\t\tMinimum (1/8) - %3.2f mph [%4d,%4d]\n", self.trackSummary.eighthMileStats.speed.min.boundedStatData*(secondsperHour/metersperMile),
								   self.trackSummary.eighthMileStats.speed.min.startIndex,
								   self.trackSummary.eighthMileStats.speed.min.endIndex))
			outputString.append(String(format: "\t\tMaximum (mile) - %3.2f mph [%4d,%4d]\n", self.trackSummary.mileStats.speed.max.boundedStatData*(secondsperHour/metersperMile),
								   self.trackSummary.mileStats.speed.max.startIndex,
								   self.trackSummary.mileStats.speed.max.endIndex))
			outputString.append(String(format: "\t\tMinimum (mile) - %3.2f mph [%4d,%4d]\n", self.trackSummary.mileStats.speed.min.boundedStatData*(secondsperHour/metersperMile),
								   self.trackSummary.mileStats.speed.min.startIndex,
								   self.trackSummary.mileStats.speed.min.endIndex))
		}
		
		// Ascent ******
		outputString.append(String(format: "\n\tAscent\n"))
		outputString.append(String(format: "\t\tMaximum (1/8)) = %5.2f feet [%4d,%4d]\n", self.trackSummary.eighthMileStats.ascent.max.boundedStatData,
								   self.trackSummary.eighthMileStats.ascent.max.startIndex,
								   self.trackSummary.eighthMileStats.ascent.max.endIndex))
		outputString.append(String(format: "\t\tMinimum (1/8)) = %5.2f feet [%4d,%4d]\n", self.trackSummary.eighthMileStats.ascent.min.boundedStatData,
								   self.trackSummary.eighthMileStats.ascent.min.startIndex,
								   self.trackSummary.eighthMileStats.ascent.min.endIndex))
		outputString.append(String(format: "\t\tMaximum (mile)) = %5.2f feet [%4d,%4d]\n", self.trackSummary.mileStats.ascent.max.boundedStatData,
																								self.trackSummary.mileStats.ascent.max.startIndex,
																								self.trackSummary.mileStats.ascent.max.endIndex))
		outputString.append(String(format: "\t\tMinimum (mile)) = %5.2f feet [%4d,%4d]\n", self.trackSummary.mileStats.ascent.min.boundedStatData,
								   self.trackSummary.mileStats.ascent.min.startIndex,
								   self.trackSummary.mileStats.ascent.min.endIndex))
		
		//  AscentRate ******
		if !self.noValidTimeEle {
			outputString.append(String(format: "\t\tMaximum Rate (1/8)) = %5.2f feet/hour [%4d,%4d]\n",
								   (self.trackSummary.eighthMileStats.ascentRate.max.boundedStatData)*(feetperMeter*secondsperHour),
								   self.trackSummary.eighthMileStats.ascentRate.max.startIndex,
								   self.trackSummary.eighthMileStats.ascentRate.max.endIndex))
			outputString.append(String(format: "\t\tMinimum Rate (1/8)) = %5.2f feet/hour [%4d,%4d]\n",
								   self.trackSummary.eighthMileStats.ascentRate.min.boundedStatData*(feetperMeter*secondsperHour),
								   self.trackSummary.eighthMileStats.ascentRate.min.startIndex,
								   self.trackSummary.eighthMileStats.ascentRate.min.endIndex))
			outputString.append(String(format: "\t\tMaximum Rate (mile)) = %5.2f feet/hour [%4d,%4d]\n",
																(self.trackSummary.mileStats.ascentRate.max.boundedStatData)*(feetperMeter*secondsperHour),
																  self.trackSummary.mileStats.ascentRate.max.startIndex,
																  self.trackSummary.mileStats.ascentRate.max.endIndex))
			outputString.append(String(format: "\t\tMinimum Rate (mile)) = %5.2f feet/hour [%4d,%4d]\n",
								   self.trackSummary.mileStats.ascentRate.min.boundedStatData*(feetperMeter*secondsperHour),
								   self.trackSummary.mileStats.ascentRate.min.startIndex,
								   self.trackSummary.mileStats.ascentRate.min.endIndex))
			outputString.append(String(format: "\t\tAverage Rate - %5.2f feet/hour\n", (self.trackSummary.totalAscent*feetperMeter) / (trackSummary.totalAscentTime == 0 ? 0 : trackSummary.totalAscentTime / secondsperHour)))
		}
		
		// Descent ******  because descents are negative numbers max and min are reversed
		//						***  bugs me that I do it here and not by swapping where I
		//								determine max/min, but there is something goofy there
		outputString.append(String(format: "\n\tDescent\n"))
		
		outputString.append(String(format: "\t\tMaximum (1/8) = %5.2f feet [%4d,%4d]\n",
								   self.trackSummary.eighthMileStats.descent.min.boundedStatData*feetperMeter,
								   self.trackSummary.eighthMileStats.descent.min.startIndex,
								   self.trackSummary.eighthMileStats.descent.min.endIndex))
		outputString.append(String(format: "\t\tMinimum (1/8) = %5.2f feet [%4d,%4d]\n",
								   self.trackSummary.eighthMileStats.descent.max.boundedStatData*feetperMeter,
								   self.trackSummary.eighthMileStats.descent.max.startIndex,
								   self.trackSummary.eighthMileStats.descent.max.endIndex))
		outputString.append(String(format: "\t\tMaximum (mile) = %5.2f feet [%4d,%4d]\n",
																self.trackSummary.mileStats.descent.min.boundedStatData*feetperMeter,
																	self.trackSummary.mileStats.descent.min.startIndex,
																	self.trackSummary.mileStats.descent.min.endIndex))
		outputString.append(String(format: "\t\tMinimum (mile) = %5.2f feet [%4d,%4d]\n",
								   self.trackSummary.mileStats.descent.max.boundedStatData*feetperMeter,
								   self.trackSummary.mileStats.descent.max.startIndex,
								   self.trackSummary.mileStats.descent.max.endIndex))
		
		// DescentRate ******  because descents are negative numbers max and min are reversed
		//						***  bugs me that I do it here and not by swapping where I
		//								determine max/min, but there is something goofy there
		if !self.noValidTimeEle {
			outputString.append(String(format: "\t\tAverage Rate - %5.2f feet/hour\n\n", (self.trackSummary.totalDescent*feetperMeter) / (trackSummary.totalDescentTime == 0 ? 0 : trackSummary.totalDescentTime / secondsperHour)))
		
			outputString.append(String(format: "\t\tMaximum Rate (1/8) = %5.2f feet/hour [%4d,%4d]\n",
								   (self.trackSummary.eighthMileStats.descentRate.min.boundedStatData)*(feetperMeter*secondsperHour),
								   self.trackSummary.eighthMileStats.descentRate.min.startIndex,
								   self.trackSummary.eighthMileStats.descentRate.min.endIndex))
			outputString.append(String(format: "\t\tMinimum Rate (1/8) = %5.2f feet/hour [%4d,%4d]\n",
								   (self.trackSummary.eighthMileStats.descentRate.max.boundedStatData)*(feetperMeter*secondsperHour),
								   self.trackSummary.eighthMileStats.descentRate.max.startIndex,
								   self.trackSummary.eighthMileStats.descentRate.max.endIndex))
			outputString.append(String(format: "\t\tMaximum Rate (mile) = %5.2f feet/hour [%4d,%4d]\n",
														(self.trackSummary.mileStats.descentRate.min.boundedStatData)*(feetperMeter*secondsperHour),
															self.trackSummary.mileStats.descentRate.min.startIndex,
															self.trackSummary.mileStats.descentRate.min.endIndex))
			outputString.append(String(format: "\t\tMinimum Rate (mile) = %5.2f feet/hour [%4d,%4d]\n",
								   (self.trackSummary.mileStats.descentRate.max.boundedStatData)*(feetperMeter*secondsperHour),
								   self.trackSummary.mileStats.descentRate.max.startIndex,
								   self.trackSummary.mileStats.descentRate.max.endIndex))
			outputString.append(String(format: "\t\tAverage Rate (mile) = %5.2f feet/hour\n", (self.trackSummary.avgDescentRateMile)*(feetperMeter*secondsperHour)))
		}
		
		for (key,value) in self.garminSummaryStats {
			outputString.append(String(format: "Garmin %@ - %@\n", key, value))
		}
		if !noConsole {
			Swift.print(outputString)
		}
		
		return outputString
	}
}


