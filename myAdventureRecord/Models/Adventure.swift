//
//  Adventure.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/7/20.
//

//****************
//	This file contains all properties, functions, and classes needed to support
//		an "Adventure".  An "Adventure" is a single row in the top level view
//		and is associated with a single trip, hike, drive, etc.
//
//	Modeled after: Landmark.swift in the Apple MacLandmarks tutorial


import SwiftUI
import ImageIO
import Foundation
import CoreLocation


struct Adventure: Hashable, Codable, Identifiable {
	var id: Int
	var name: String
	var imageName: String = "myHikingRecordIcon"
	var hikeDate : String
	var area : String						// future use: will be the geographic area of hike (e.g. RMNP)
	var coordinates = Coordinates()			// generally will be the lat,long of first trackpt
	var trackData = Track()					// all track summary data
	var trackPtList = [Trkpt]()				// all recorded gps track points
	var description: String					// used to provide short hike description
	var isFavorite : Bool					// favorite button
	
	var locationCoordinate : CLLocationCoordinate2D {	// used to set center of map
		CLLocationCoordinate2D( latitude: coordinates.latitude, longitude: coordinates.longitude)
	}
	var longitudeSpan : CLLocationDegrees
	var latitudeSpan: CLLocationDegrees
	
	var difficulty : Color {
		let difficultyScore =  ((trackData.trackSummary.totalAscent * 3.281) * 2 * (trackData.trackSummary.distance/1000)).squareRoot()
					// from Shenandoah National Park Difficulty Rating
		switch difficultyScore {
		case ..<50: return Color(.green)
		case 50 ..< 100: return Color(.blue)
		case 100 ..< 150: return Color(.yellow)
		case 150 ..< 200: return Color(.orange)
		
		default:
			return Color(.red)
		}
	}
	// future use
	enum Category : String, CaseIterable, Identifiable, Codable {
		case hike = "Hike"
		case walkabout = "Walkabout"
		case orv = "Off Road"
		case scenicDrive = "Scenic Drive"
		case snowshoe = "Snowshoe"
		case none = "Not Categorized"
		
		var id : Category { self }
	}
	
	var hikeCategory : Category
	
	init() {
		self.id = 0
		self.isFavorite = true
		self.name = ""
		//self.imageName = ""
		self.area = ""
		self.trackData = Track()
		self.description = ""
		self.hikeDate = ""
		self.longitudeSpan = CLLocationDegrees(0.02)
		self.latitudeSpan = CLLocationDegrees(0.02)
		self.hikeCategory = Category.none
		
	}
}

extension Adventure {
	var image: Image {
		ImageStore.shared.image(name: imageName)
	}
}

//****************
//	End Adventure
//

struct Coordinates: Hashable, Codable {
	// Home coordiinates as default
	var latitude: Double = 40.36526
	var longitude: Double = -105.10083
	var maxLongitude: Double = 0
	var maxLatitude: Double = 0
	var minLongitude: Double = 0
	var minLatitude: Double = 0
}
