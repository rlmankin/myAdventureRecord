//
//  myHikingRecord
//
//  Created by Robb Mankin on 12/6/20.
//
//	This file contains all properties, functions, and classes necessary to
//		source all data (images, tracks, trkpts, etc) to support the application
//
//	Modeled after: Data.swift in the Apple MacLandmarks tutorial

import Foundation
import SwiftUI
import ImageIO
import CoreLocation



let sqlHikingData = SqlHikingDatabase()								// 	open and load the various tables from the database
var adventureData: [Adventure]  = loadAdventureData()				// 	create adventures from track data in the databse

func loadAdventureData() -> [Adventure] {
	//	loadAdventureData loops through all tracks in the database and creates the adventure structure for all entries.
	//	returns an array of adventures.  This array is later used & published by the UserData class for use throughout
	//	the application
	timeStampLog(message: "-> loadAdventureData")
	var adventures = [Adventure]()									//	adventures is the overall return array structure
	var localAdventure = Adventure()								//	localAdventure is a temporary store for creating an adventure
	for item in sqlHikingData.tracks {
		//let lhsDate = timeStampLog(message: "-> \(item.header)", noPrint: true)
		// do not load the trkptsList now but defer to the first attempt by the user to look at an adventure's Detail (AdventureDetail)
		// 	I've learned that loading the trkptsList is the largest time consumer and when mulitplied over a large number of database
		//	entries the load time for the app is unacceptable
		//print("loadAdventureData:  \(item.trkUniqueID), \(item.header)")
			// load track parameters into the adventure
		localAdventure = loadAdventureTrack(track: item)
			// load adventure parameters from 'adventure table' into the adventure.  NOTE:  localAdventure is passed as reference (&localAdventure)
			//	to ensure I use the same instance
		sqlHikingData.sqlRetrieveAdventure(item.trkUniqueID, &localAdventure)
		if localAdventure.associatedTrackID != item.trkUniqueID {
				//print("mismatch \(item.header) - repairing", terminator: " ")
			sqlHikingData.repairAssociatedTrackID(trkUniqueID: item.trkUniqueID, associatedTrackID: localAdventure.associatedTrackID)
				//print(" - completed")
		}
			//localAdventure.prettyPrint()									// print the major parts of the adventure (debug)
		adventures.append(localAdventure)
		localAdventure = Adventure()										// reinit the adventure
		//timeStamp(message: "<- \(item.header)")
		
	}
	timeStampLog(message: "<- trackLoadTime")
	let nilStarts = adventures.map({$0.trackData.trackSummary.startTime == nil})
	for index in (0 ..< nilStarts.endIndex) {
		if nilStarts[index] { 	// adventure startTime is nil
			let dc = DateComponents(year: 2013, month: 01, day: 01)
			adventures[index].trackData.trackSummary.startTime = Calendar.current.date(from: dc)	// set nil entries to 01/01/2013
			print("nil date found: \(index)")
		}
	}
	adventures.sort( by: { $0.trackData.trackSummary.startTime! >= $1.trackData.trackSummary.startTime!})
	timeStampLog(message: "<-loadAdventureData")
	return adventures
}


func loadAdventureTrack(track: Track) -> Adventure {
	// NOTE: this is not a complete adventure, only the parts of the adventure structure found in the track structure
	// loadAdventureTrack fills all applicable adventure fields from a track structure
	// 	the trackpoints list is retrieved in AdventureDetail when that adventure is requested
	// this function is called throughout the app, so there should be no time consuming acticities in here (e.g.
	//	calls to retrieve information from the database
	//timeStampLog(message: "-> loadAdventureTrack")
	var adventure = Adventure()
	
	adventure.id = track.trkUniqueID								// 	trkUniqueID is the critical field.  It is used to link all table entries
																	// 	to a specific track in the database
	adventure.associatedTrackID = track.trkUniqueID
	adventure.name = track.header									// 	the track header will always be used to name the adventure
	adventure.trackData = track										// 	load the trackData field with the track.
		// if a garminDistance value exists use it as the adventure distance instead of the trackSummary value.  Garmin track distance
		//	is a more accurate reading of the overall distance than the summing of the distances between trackpoints.  Trackpoin summing
		//	introduces sample rate error and is usually shorter than the garmin distance.
	if let garminDistance = track.garminSummaryStats["Distance"] {
		adventure.distance = Double(garminDistance)!
	} else {
		adventure.distance = track.trackSummary.distance
	}
	
		
	adventure.trackData.trkptsList = track.trkptsList
		// 	if there is no trackpoint list, then defer loading all latitude/longitude related adventure items to AdventureDetail
		//	set the hike date, using the 'usual' Apple date functions.  NOTE:  this uses a Swift closure, unusual for me to use.
	adventure.hikeDate = {
		let dateFmt = DateFormatter()
		dateFmt.timeZone = TimeZone.current
		dateFmt.dateFormat =  "MMM dd, yyyy"
			//	probably should 'guard' this to avoid an unexpected crash for nil
		return String(format: "\(dateFmt.string(from: track.trackSummary.startTime ?? Date()))")
	}()
		
	//timeStampLog(message: "<- loadAdventureTrack")
	
	return adventure
}

func loadPartialAdventure(partial: Adventure, target: inout Adventure) {
	//	loadPartialAdventure loads those parts of the adventure structure that are carried in the 'adventureTable' in the database
	//		NOTE: target is a inout parameter, thus making it pass-by-reference.  This is necessary to insure the same instance of
	//				adventure is modified and not a new one
	target.imageName = partial.imageName
	target.area = partial.area
	target.description = partial.description
	target.hikeCategory = partial.hikeCategory
	target.isFavorite = partial.isFavorite
}

final class ImageStore {
	
	typealias _ImageDictionary = [String: CGImage]
	fileprivate var images: _ImageDictionary = [:]

	private static var scale = 2
	
	static var shared = ImageStore()
	
	func image(name: String) -> Image {
		let index = _guaranteeImage(name: name)
		
		return Image(images.values[index], scale: CGFloat(ImageStore.scale), label: Text(name))
	}

	static func loadImage(name: String) -> CGImage {
		
		// I'm sure there is a more elegant way to achieve the functionality of determining
		//	if an image with an extension of either .jpg OR .jpeg exist, but this works for now
		var fullPathString = NSSearchPathForDirectoriesInDomains(
									.documentDirectory, .userDomainMask, true).first!
							 +  "/hiking/hikingDatabase/thumbnails/" + name + " thumb"
		if FileManager.default.fileExists(atPath: fullPathString + ".jpg") {
			fullPathString = fullPathString + ".jpg"
		}
		if FileManager.default.fileExists(atPath: fullPathString + ".jpeg") {
			fullPathString = fullPathString + ".jpeg"
		}
		if !FileManager.default.fileExists(atPath: fullPathString) {
			fullPathString = NSSearchPathForDirectoriesInDomains(
				.documentDirectory, .userDomainMask, true).first!
						+  "/hiking/hikingDatabase/thumbnails/myHikingRecordIcon thumb.jpg"
		}
		let url = NSURL(fileURLWithPath: fullPathString)
		let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil)
		let image = CGImageSourceCreateImageAtIndex(imageSource!, 0, nil)
		
		return image!
	}
	
	fileprivate func _guaranteeImage(name: String) -> _ImageDictionary.Index {
		if let index = images.index(forKey: name) { return index }
		
		images[name] = ImageStore.loadImage(name: name)
		return images.index(forKey: name)!
	}

}
