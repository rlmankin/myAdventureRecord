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


typealias Categorizable = CaseIterable
						& Identifiable
						& Hashable
						& CustomStringConvertible

struct CategoryPicker<Enum: Categorizable, Label: View>: View {
	
	private let label: Label
	
	@Binding private var selection: Enum

	var body: some View {
		Picker(selection: $selection, label: label) {
			ForEach(Array(Enum.allCases)) { value in
				Text(value.description).tag(value)
			}
			
		}
	}
	
	init(selection: Binding<Enum>, label: Label) {
		self.label = label
		_selection = selection
	}
}
extension CategoryPicker where Label == Text {

	init(_ titleKey: LocalizedStringKey, selection: Binding<Enum>) {
		label = Text(titleKey)
		_selection = selection
	}

	init<S: StringProtocol>(_ title: S, selection: Binding<Enum>) {
		label = Text(title)
		_selection = selection
	}
}

struct Adventure: Hashable, Codable, Identifiable {
	var id: Int
	var associatedTrackID : Int
	var name: String
	var imageName: String = "myHikingRecordIcon"
	var hikeDate : String
	var distance : Double
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
	enum HikeCategory : String, Codable,  Categorizable {
		case hike
		case walkabout
		case orv
		case scenicDrive
		case snowshoe
		case none
		
		var id : HikeCategory { self }
		
		var description: String {
			switch self {
			case .hike: return "Hike"
			case .walkabout: return "Walkabout"
			case .orv : return "Off Road"
			case .scenicDrive: return "Scenic Drive"
			case .snowshoe : return "Snowshoe"
			case .none : return "Not Categorized"
			
			}
		}
	}
	
	var hikeCategory : HikeCategory
	
	init() {
		self.id = 0
		self.associatedTrackID = 0
		self.isFavorite = true
		self.name = ""
		self.distance = 0.0
		self.area = ""
		self.trackData = Track()
		self.description = ""
		self.hikeDate = ""
		self.longitudeSpan = CLLocationDegrees(0.02)
		self.latitudeSpan = CLLocationDegrees(0.02)
		self.hikeCategory = HikeCategory.none
		
	}
	
	func prettyPrint() {
		
		var outputString : String = nullString
		
		outputString.append(String(format:"%@\t ", self.trackData.id.uuidString))
		outputString.append(String(format:"%4d\t ", self.trackData.trkUniqueID))
		//outputString.append("Adventure:  ")
		outputString.append(String(format:"%4d\t ", self.id))
		outputString.append(String(format:"%4d\t ", self.associatedTrackID))
		outputString.append(String(format:"%@\t ", self.name))
		outputString.append(String(format:"%@\t ", self.area))
		outputString.append(String(format:"%@\t ", self.description))
		outputString.append(String(format:"%@", self.hikeCategory.description))
		
		print(outputString)
	}
}

extension Adventure {
	var image: Image { ImageStore.shared.image(name: name)
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
