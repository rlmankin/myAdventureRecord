//
//  ContentView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 2/3/21.
//

import SwiftUI

struct NavButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.caption)
			.padding(2)
			.foregroundColor(Color.white)
			.background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .leading, endPoint: .trailing))
			.cornerRadius(5)
			.opacity(configuration.isPressed ? 1.0 : 0.8)
			.scaleEffect(configuration.isPressed ? 1.2 : 1)
	}
}

struct DetailButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding(5)
			.foregroundColor(Color.black)
			.background(LinearGradient(gradient: Gradient(colors: [Color.gray, Color.white]), startPoint: .leading, endPoint: .trailing))
			.cornerRadius(5)
			.opacity(configuration.isPressed ? 1.0 : 0.8)
			.scaleEffect(configuration.isPressed ? 1.2 : 1)
	}
}

struct ContentView: View {
	@EnvironmentObject var userData: UserData
	
	@ViewBuilder										// use @ViewBuilder to allow for the return of different View type.
	var body: some View {
		if userData.adventures.isEmpty {
			VStack {
				Text("Loading all your adventures...")
				ProgressView() //Text("Loading ...")
					.task {
						 await userData.loadUserData()
					}
			}.frame(minWidth: 1200, idealWidth: 1800, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,  minHeight: 800, idealHeight: 1000, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
		} else {
			AdventureList()
				.frame(minWidth: 1200, idealWidth: 1800, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,  minHeight: 800, idealHeight: 1000, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
		}
	}
	
}


struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
			.environmentObject(UserData())
			
		
	}
}
