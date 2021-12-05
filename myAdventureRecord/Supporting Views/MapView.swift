//
//  MapView.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/16/20.
//

import SwiftUI
import MapKit

struct MapView : View {
	var coordinate: CLLocationCoordinate2D
	var track : Track
	

	func makeMapView() -> MKMapView {
		return MKMapView(frame: .zero)
		
	}
	func makeCoordinator() -> MapViewCoordinator {
		// This method is implicitly called when creating the mapView coodinator
		//	& delegate in updateMapView (below)
		MapViewCoordinator(self)
	}
	
	func convertTrkPtToLocation(_ trkpts : [Trkpt]) -> [CLLocationCoordinate2D] {
		// 	convert the trackpoint list (latitude, longitude) to an array
		//	CLLocataionCoordinate2D for use in MapKit functions
		
		
	
		var locations = [CLLocationCoordinate2D]()
	
		guard !trkpts.isEmpty else { return locations }	// return just in case
					// the trackpoint list is empty
			for i in 0 ..< trkpts.endIndex {
				let location = CLLocationCoordinate2D(latitude: trkpts[i].latitude,
													  longitude: trkpts[i].longitude)
				locations.append(location)
			}
		return locations
	}
	
	func convertLocationsToAnnotations( _ locations : [CLLocationCoordinate2D]) -> [MKPointAnnotation] {
		// convert the trackpoint list [CLLocationCoordinate2D] to an array of
		//	Mapkit point annotations [MKPointAnnotations].
		
		//	I've chosen to separate the conversion from trackpoint latitude and
		//	longitude into two steps in case I later want to use the
		//	convertTrkPtToAnnotations method for waypopints.  It is not needed
		//	to display the track
		
		
		var location : CLLocationCoordinate2D
		
		var annotations =  [MKPointAnnotation]()
		guard !locations.isEmpty else {return annotations}
		
		for i in 0 ..< locations.endIndex {
			let annotation = MKPointAnnotation()
			location = locations[i]
			annotation.coordinate = location
			annotation.title = String(format: " %5.4f ", location.latitude)
			annotations.append(annotation)
			
		}
		return annotations
		
	}

	
	
	func updateMapView(_ view: MKMapView, context: Context) {
		view.delegate = context.coordinator
			// instantiates a MapViewCoordinatpr and sets it as the MapView
			//	delegate to create an renderer for annotations and enable
			//	map movement
		let minLat = track.trkptsList.compactMap({$0.latitude}).min()!
		let maxLat = track.trkptsList.compactMap({$0.latitude}).max()!
		let minLon = track.trkptsList.compactMap({$0.longitude}).min()!
		let maxLon = track.trkptsList.compactMap({$0.longitude}).max()!
		let deltaLat = maxLat - minLat
		let deltaLon = maxLon - minLon
		let span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(1.25*deltaLat),
									longitudeDelta: CLLocationDegrees(1.2*deltaLon))
		//let span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.2),
		//							longitudeDelta: CLLocationDegrees(0.2))
			// set up a "standard" span of 0.2 degrees.  I may change this later
			// to set the span to be the size of the track 'bounding box'
		// if more than one detail tab is available, this statement will crash with a parallel access error
		//		Need to find a way to either put some kind of semaphore in or grant shared access.
		
		let center = CLLocationCoordinate2D(latitude: minLat + deltaLat/2, longitude: minLon + (deltaLon)/2)
		let region = MKCoordinateRegion(center: center, span: span)
		view.setRegion(region, animated: true)	// true - animate the map transition.  false -show the map immediately
		view.mapType = .hybrid
		
		
		
		// route (test case for now)
		let trkPtAsLocations = convertTrkPtToLocation(track.trkptsList)
		//let trkPtAsAnnotations = convertLocationsToAnnotations(trkPtAsLocations)
		//  trkPtAsAnnotations is currently not used to provide base functions for displaying waypoints later
		//trailhead marker
		let centerpoint = MKPointAnnotation()
		centerpoint.title = "center"
		centerpoint.coordinate = center
		view.addAnnotation(centerpoint)
		
		let trailHead = MKPointAnnotation()
		trailHead.title = "trailhead"
		trailHead.coordinate = trkPtAsLocations[0]
		view.addAnnotation(trailHead)
		//view.addAnnotations(y)
		let polyline = MKPolyline(coordinates: trkPtAsLocations, count: trkPtAsLocations.count)
		view.addOverlay(polyline)
		//let mapRect = polyline.boundingMapRect
		//view.setVisibleMapRect(mapRect, animated: true)
		view.addOverlay(polyline)
 
	}
}

extension MapView: NSViewRepresentable {
	func makeNSView(context: Context) -> MKMapView {
		return  makeMapView()
	}
	
	func updateNSView(_ nsView: MKMapView, context: Context) {
		updateMapView(nsView, context: context)
	}
}


class MapViewCoordinator: NSObject, MKMapViewDelegate {
	// The MapViewCoordinator class must exist to provide a rendering capability
	//	for annotations (waypoint and track).  It must be a subclass of NSObject
	//	and adhere to the MKMapViewDelegate protocol
	var mapViewController: MapView
	init(_ control: MapView){
		self.mapViewController = control
	}
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		let renderer = MKPolylineRenderer(overlay: overlay)
		renderer.fillColor = .red
		renderer.strokeColor = .blue
		renderer.lineWidth = 2
		return renderer
	}
	
}


struct MapView_Previews: PreviewProvider {
	static var previews: some View {
		MapView(coordinate: adventureData[0].locationCoordinate,
				track: adventureData[0].trackData)
	}
}


