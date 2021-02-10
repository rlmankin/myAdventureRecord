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
		
		
		ScrollView {
			ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
					// ZStack for the map and 'open in maps' overlay
				
				MapView(coordinate: adventure.locationCoordinate,
						track: adventure.trackData)
				.frame(height:300)
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
				CircleImage(image: adventure.image.resizable())
					.offset(x:10, y: 120)
			
					.frame(width: 150, height:150)
				
			}
			
			VStack (alignment: .leading, spacing: 0) {
				// Vstack for all Text, impages, and graphs
				HStack( alignment: .center, spacing: 12) {
					// HStack for image, title, and coordinates
					//CircleImage(image: adventure.image.resizable())
					//	.offset(x:10, y: -50)
					//	.frame(width: 200, height:200)
					//	.background(Color.gray)
					Text("").frame(width: 200,height: 150,  alignment: .center)
					VStack(alignment: .center) {
						HStack (alignment: .center) {
							Text(adventure.name).font(.title).italic()
							Button(action: {
								self.userData.adventures[self.adventureIndex]
									.isFavorite.toggle()
							}) {
								if userData.adventures[self.adventureIndex].isFavorite {
									Image("star-filled")
										.resizable()
										.renderingMode(.template)
										.accessibility(label: Text("Remove from favorites"))
								} else {
									Image("star-empty")
										.resizable()
										.renderingMode(.template)
										.foregroundColor(.gray)
										.accessibility(label: Text("Add to favorites"))
								}
							}	//button
							.frame(width: 20, height: 20)		// Need frame to keep star small
							.buttonStyle(PlainButtonStyle())
						}
						Text(String(format: "location: %5.3f , %5.3f", adventure.coordinates.latitude,adventure.coordinates.longitude))
							.font(.headline).italic()
							.foregroundColor(.secondary)
						
					}
					
				} //HStack
				VStack( alignment: .leading) {
					// Vstack for Description Title and Description
					Divider()
					HStack (alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 20) {
						Text("About \(adventure.name)").background(Color.gray)
							.font(.headline)
						Spacer()
						if let x = adventure.trackData.trackSummary.startTime {
							Text(x, style: .date).padding(.trailing, 30)
						}
						
						
					}
					Text(adventure.description+"jfkljdalkgjflkajgklfjlkgjfklgjflkagjlkgjakfljgfkld ")
						//.background(Color.blue)
						.offset(x:10)
				}.offset(x:10)
				
			}//.background(Color.orange)
			
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
					Image(systemName: "charr.bar.fill")
					Text("Summary")
				})
			
		}.frame(minWidth: 500, idealWidth: 500, maxWidth: .infinity, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 400, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
		
		
		
		
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
