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
	
	// future use
	enum Category {
		case hike
		case walkabout
		case orv
		case scenicDrive
	}
	
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
