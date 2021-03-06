//
//  CircleImage.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/16/20.
//

import SwiftUI

struct CircleImage: View {
	var image: Image
	var shadowRadius: CGFloat = 10

	var body: some View {
		image
			.clipShape(Circle())
			.overlay(Circle().stroke(Color.white, lineWidth: 4))
			.shadow(radius: shadowRadius)
	}
}

struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
		CircleImage(image: Image("Annie"))
    }
}
