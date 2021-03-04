//
//  GetSqlDatabase.swift
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

var adventureData: [Adventure] = loadAdventureData()

func loadAdventureTrack(track: Track) -> Adventure {
	var adventure = Adventure()
	adventure.id = track.trkIndex
	adventure.name = track.header
	adventure.imageName = "myHikingRecordIcon"
	adventure.description = track.trackComment
	adventure.trackData = track
	adventure.trackData.trkptsList = track.trkptsList
	//print(adventure.name, adventure.id, track.trkIndex, adventure.trackData.trkptsList.count)
	if adventure.trackData.trkptsList.count != 0 {
		adventure.coordinates.latitude = adventure.trackData.trkptsList[0].latitude
		adventure.coordinates.longitude = adventure.trackData.trkptsList[0].longitude
		
		adventure.coordinates.maxLatitude = adventure.trackData.trkptsList.compactMap({$0.latitude}).max()!
		adventure.coordinates.maxLongitude = adventure.trackData.trkptsList.compactMap({$0.longitude}).max()!
		adventure.coordinates.minLatitude = adventure.trackData.trkptsList.compactMap({$0.latitude}).min()!
		adventure.coordinates.minLongitude = adventure.trackData.trkptsList.compactMap({$0.longitude}).min()!
		adventure.latitudeSpan = CLLocationDegrees( max( abs( adventure.coordinates.latitude - adventure.coordinates.maxLatitude),
									  abs( adventure.coordinates.latitude - adventure.coordinates.minLatitude)))
		adventure.longitudeSpan = CLLocationDegrees(max( abs( adventure.coordinates.longitude - adventure.coordinates.maxLongitude),
									  abs( adventure.coordinates.longitude - adventure.coordinates.minLongitude)))
	}
	adventure.hikeDate = {
		let dateFmt = DateFormatter()
		dateFmt.timeZone = TimeZone.current
		dateFmt.dateFormat =  "MMM dd, yyyy"
		return String(format: "\(dateFmt.string(from: track.trackSummary.startTime!))")
	}()
	return adventure
}

func loadAdventureData() -> [Adventure] {
	var adventure = Adventure()
	var adventures = [Adventure]()
	let sqlHikingData = SqlHikingDatabase()
	let sqlTrkptsData = SqlTrkptsDatabase()
	for var item in sqlHikingData.tracks {
		//var track = item
		item.trkptsList = sqlTrkptsData.sqlRetrieveTrkptlist(item.trkIndex)
		
		adventure = loadAdventureTrack(track: item)

		adventures.append(adventure)
		adventure = Adventure()	// reinit the adventure
	}
	adventures.sort( by: { $0.trackData.trackSummary.startTime! >= $1.trackData.trackSummary.startTime!})
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

}
