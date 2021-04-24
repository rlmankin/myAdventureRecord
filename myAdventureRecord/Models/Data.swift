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

var adventureData: [Adventure]  = loadAdventureData()				// 	create adventures from track data in the databse

let sqlHikingData = SqlHikingDatabase()								// 	open and load the various tables from the database

func loadTrackFromAdventure(adventure: Adventure) -> Track {
	return adventure.trackData
}

func loadAdventureTrack(track: Track) -> Adventure {
	// loadAdventureTrack fills all applicable adventure fields from a track structure
	// 	the trackpoints list is retrieved in the parent function or is already carried within the track structure
	// this function is called throughout the app, so there should be no time consuming acticities in here (e.g.
	//	calls to retrieve information from the database
	var adventure = Adventure()
	
	adventure.id = track.trkUniqueID								// 	trkUniqueID is the critical field.  It is used to link all table entries
																	// 	to a specific track in the database
	adventure.name = track.header									// 	the track header will always be used to name the adventure
	adventure.trackData = track										// 	load the trackData field with the track.
	
	//	DO NOT replace this line will a call to retrieve the trackpoint list.
		adventure.trackData.trkptsList = track.trkptsList
		//	if there are no trackpoints the there is no need to calculate andy additional fields
	if !adventure.trackData.trkptsList.isEmpty {
			//	coordinates set the center of the map at the starting location and hold the maximum/minimum latitude/longitude to set the area
			//	of the track.  This is used to set the center and area of the map
		adventure.coordinates.latitude = adventure.trackData.trkptsList[0].latitude
																	//	find the latitude of the start of the track
		adventure.coordinates.longitude = adventure.trackData.trkptsList[0].longitude
																	//	find the longitude of the start of the track
				// find the maximum latitude and longitude.
			//	probably should 'guard' these to avoid an unexpected crash for nil
		adventure.coordinates.maxLatitude = adventure.trackData.trkptsList.compactMap({$0.latitude}).max()!
		adventure.coordinates.maxLongitude = adventure.trackData.trkptsList.compactMap({$0.longitude}).max()!
				// find the minumum latitude and longitude
		adventure.coordinates.minLatitude = adventure.trackData.trkptsList.compactMap({$0.latitude}).min()!
		adventure.coordinates.minLongitude = adventure.trackData.trkptsList.compactMap({$0.longitude}).min()!
				// calculate the 'span' of the latitude and longitude.  This sets the various 'corners' of the map
		adventure.latitudeSpan = CLLocationDegrees( max( abs( adventure.coordinates.latitude - adventure.coordinates.maxLatitude),
									  abs( adventure.coordinates.latitude - adventure.coordinates.minLatitude)))
		adventure.longitudeSpan = CLLocationDegrees(max( abs( adventure.coordinates.longitude - adventure.coordinates.maxLongitude),
									  abs( adventure.coordinates.longitude - adventure.coordinates.minLongitude)))
	}
	adventure.hikeDate = {											//	set the hike date, using the 'usual' Apple date functions
		let dateFmt = DateFormatter()
		dateFmt.timeZone = TimeZone.current
		dateFmt.dateFormat =  "MMM dd, yyyy"
			//	probably should 'guard' this to avoid an unexpected crash for nil
		return String(format: "\(dateFmt.string(from: track.trackSummary.startTime!))")
	}()
		// return, NOTE: this is not a complete adventure, only the parts of the adventure structure used by a track
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


func loadAdventureData() -> [Adventure] {
	//	loadAdventureData loops through all tracks in the database and creates the adventure structure for all entries.
	//	returns and array of adventures.  This array is later used & published by the UserData class for use throughout
	//	the application
	timeStampLog(message: "-> loadAdventureData")
	
	var localAdventure = Adventure()
	var adventures = [Adventure]()
	//var cumTrkptListLoadTime : Double = 0.0
	for item in sqlHikingData.tracks {
		//let lhsDate = timeStampLog(message: "-> \(item.header)", noPrint: true)
		// do not load the trkptsList now but defer to the first attempt by the user to look at an adventure's Detail (AdventureDetail)
		// 	I've learned that loading the trkptsList is the largest time consumer and when mulitplied over a large number of database
		//	entries the load time for the app is unacceptable
		//item.trkptsList = sqlHikingData.sqlRetrieveTrkptlist(item.trkUniqueID)
																	//	retrieve the trackspoint list from the trackpointlist table in the database
		//let rhsDate = timeStampLog(message: "\(item.trkptsList.count)", noPrint: true)
		//cumTrkptListLoadTime += rhsDate - lhsDate
		//print("\(Int((rhsDate - lhsDate)*1000))ms : \(item.trkptsList.count) - \(item.header)")
		localAdventure = loadAdventureTrack(track: item)					// load track parameters into the adventure
		sqlHikingData.sqlRetrieveAdventure(item.trkUniqueID, &localAdventure)
																	// load adventure parameters into the adventure
		//timeStamp(message: "<- item.adventure")
		//localAdventure.imageName = localAdventure.imageName
		adventures.append(localAdventure)
		localAdventure = Adventure()										// reinit the adventure
		//timeStamp(message: "<- \(item.header)")
		
	}
	//print("Total TrkptLoadTime = \(cumTrkptListLoadTime)")
	adventures.sort( by: { $0.trackData.trackSummary.startTime! >= $1.trackData.trackSummary.startTime!})
	timeStampLog(message: "<-loadAdventureData")
	return adventures
}
//****************
// The following are copied from the MacLandmarks tutorial.  I need to understand
//	them before deciding if I should replace my versions with these.
//	Note: as of 12/7/2020, I do not have an alternative to the "ImageStore" class
//****************

/*func load<T: Decodable>(_ filename: String) -> T {
	let data: Data
	
	guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
	else {
		fatalError("Couldn't find \(filename) in main bundle.")
	}
	
	do {
		data = try Data(contentsOf: file)
	} catch {
		fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
	}
	
	do {
		let decoder = JSONDecoder()
		return try decoder.decode(T.self, from: data)
	} catch {
		fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
	}
}
*/

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
	
		var fullPathString = NSSearchPathForDirectoriesInDomains(
									.documentDirectory, .userDomainMask, true).first!
							 +  "/hiking/hikingDatabase/thumbnails/" + name + " thumb.jpg"
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

//   Original ImageStore Class

/*final class ImageStore {
	typealias _ImageDictionary = [String: CGImage]
	fileprivate var images: _ImageDictionary = [:]

	private static var scale = 2
	
	static var shared = ImageStore()
	
	func image(name: String) -> Image {
		let index = _guaranteeImage(name: name)
		
		return Image(images.values[index], scale: CGFloat(ImageStore.scale), label: Text(name))
	}

	static func loadImage(name: String) -> CGImage {
		guard
			let url = Bundle.main.url(forResource: name, withExtension: "jpg"),
			let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
			let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
		else {
			fatalError("Couldn't load image \(name).jpg from main bundle.")
		}
		return image
	}
	
	fileprivate func _guaranteeImage(name: String) -> _ImageDictionary.Index {
		if let index = images.index(forKey: name) { return index }
		
		images[name] = ImageStore.loadImage(name: name)
		return images.index(forKey: name)!
	}

}*/
