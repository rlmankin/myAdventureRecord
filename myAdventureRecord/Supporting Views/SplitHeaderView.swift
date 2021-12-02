//
//  SplitHeaderView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 12/1/21.
//

import SwiftUI


struct SplitHeaderView: View {
	var header: String
	var value: [String]
	var format: [Int]
	var width: [CGFloat]
	var fixedLength : Int
	
	func padStringWithFormat (value : String, format: Int) -> String {
		var formattedValue = value
		let stringLength : Int = value.count
		
		
		if stringLength <= fixedLength {
			formattedValue = String(repeating: " ", count: fixedLength - stringLength) + formattedValue
		}
		return formattedValue
	}
	
    var body: some View {
		VStack {
			Text("\(header)")
			HStack {
				HStack {
					Text(padStringWithFormat(value:value[0], format:format[0]))
					Text(padStringWithFormat(value: value[1], format: format[1]))
				}.frame(width: width[0])
				Rectangle()
					.fill(.clear)
					.frame(width: width[1])
				HStack {
					Text(padStringWithFormat(value: value[2], format: format[2]))
					Text(padStringWithFormat(value: value[3], format: format[3]))
				}.frame(width: width[2])
			}.frame(height: 15)
				.border(.blue)
		}

    }
}

struct SplitHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SplitHeaderView(header: "Mile Splits", value: ["#","mph","feet","grade"], format: [3,3,6,3], width: [120,280,150], fixedLength: 8)
    }
}
