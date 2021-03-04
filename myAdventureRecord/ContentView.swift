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
			.padding(5)
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
	
	
	
	var body: some View {
		
		AdventureList()
			.frame(minWidth: 500, idealWidth: 900, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,  minHeight: 1000, idealHeight: 1200, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
	}
	
}


struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		
			ContentView()
				.environmentObject(UserData())
			
		
	}
}
