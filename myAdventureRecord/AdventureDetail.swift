//
//  AdventureDetail.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/16/20.
//

import SwiftUI
import MapKit

struct AdventureDetail: View {
	
	@EnvironmentObject var userData: UserData
	

	var adventure: Adventure
	
	var adventureIndex: Int {
		userData.adventures.firstIndex(where: { $0.id == adventure.id})!
	}
	
	var body: some View {
		
		
		ScrollView  {
			ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
				// ZStack for the map and 'open in maps' overlay
				
				MapView(coordinate: adventure.locationCoordinate,
						track: adventure.trackData)
					.frame(height:350)
					.overlay(
						GeometryReader { proxy in
							Button("Open in Maps") {
								let destination = MKMapItem(placemark: MKPlacemark(coordinate: self.adventure.locationCoordinate))
								destination.name = self.adventure.name
								destination.openInMaps()
							}
							.frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottomTrailing)
							.offset(x: -10, y: -10)
						}
					)
				//CircleImage(image: adventure.image.resizable())
				//	.offset(x:5, y: 135)
					
				//	.frame(width: 150, height:150)
				
			}
			AdventureSection2View(adventure: adventure)
			
			
			
			// TabView for graphing buttons
			TabView {
				DistanceElevationTab(adventure: adventure)
					.tabItem({
								Image(systemName: "thermometer")
								Text("Elevation")})//.background(Color.red)
				DistanceGradeTab(adventure: adventure)
					.tabItem({
								Image(systemName: "chart.bar.fill")
								Text("Grade")})
				DistanceSpeedTab(adventure: adventure)
					.tabItem({
								Image(systemName: "chart.bar.fill")
								Text("Speed")})
				SummaryTab(adventure: adventure)
					.tabItem({
						Image(systemName: "chart.bar.fill")
						Text("Summary")
					})
				
			}.frame(minWidth: 500, idealWidth: 500, maxWidth: .infinity, minHeight: 0/*@END_MENU_TOKEN@*/, idealHeight: 400, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center)
			
			
			
			
		}  // Scrollview
		//.frame(minWidth: 500, idealWidth: 500, maxWidth: .infinity, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 400, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
}

struct AdventureDetail_Previews: PreviewProvider {
    static var previews: some View {
        AdventureDetail(adventure: adventureData[0])
			.environmentObject(UserData())
			.frame(width: 850, height: 900)
    }
}
}
