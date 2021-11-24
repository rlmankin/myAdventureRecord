//
//  SplitsChartView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 11/24/21.
//

import SwiftUI

struct SplitsChartView: View {
	var avgSpeed : Double = 0.0
	var maxSpeed : Double = 0.0
	
	
    var body: some View {
        GeometryReader { reader in
			let chartWidth : CGFloat = reader.size.width*0.75
			let chartHeight : CGFloat = reader.size.height
			let rect : CGRect = CGRect(x: 0, y: 0, width: avgSpeed/maxSpeed*chartWidth, height: 0.9*chartHeight)
			Path { p in
				p.addRoundedRect(in: rect, cornerSize: CGSize(width: 0.09*chartHeight, height: 0.09*chartHeight))
				
			}
		}
    }
}

struct SplitsChartView_Previews: PreviewProvider {
    static var previews: some View {
		SplitsChartView(avgSpeed: 2.0, maxSpeed: 3.0)
    }
}
