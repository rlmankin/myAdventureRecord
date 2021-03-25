//
//  GrainTriangleView.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 1/17/21.
//

import SwiftUI

struct GainTriangleView: View {
	var readerHeight : CGFloat
	var startXOffset : CGFloat
	var endXOffset : CGFloat
	
	var startYHeight : CGFloat
	var endYHeight : CGFloat
	
	var distX : Double
	var distY: Double
	
	var color: Color
	
	
	
    var body: some View {
		let deltaHeight = (endYHeight - startYHeight)/CGFloat(2.0)
		
		GeometryReader { reader in
			Path { p in
				p.move( to: CGPoint(x: startXOffset, y: readerHeight - startYHeight))
				p.addLine( to: CGPoint(x: endXOffset, y: readerHeight - startYHeight))
				p.addLine(to: CGPoint(x: endXOffset, y: readerHeight - endYHeight))
			}.stroke(color, style: StrokeStyle(dash: [2]))
			 .offset(x:30, y:0)
	
			Text(String( format: "\n%2.2f", distX))
				.font(.footnote)
				.foregroundColor(color)
				.offset(x: CGFloat(endXOffset + 10),
						y: CGFloat(readerHeight - startYHeight - 23))
			Text(String( format: "\n%2.2f", distY))
				.font(.footnote)
					.foregroundColor(color)
					.rotationEffect(.degrees(-90))
					.offset(x: CGFloat(endXOffset),
							y: CGFloat(readerHeight - endYHeight + deltaHeight))
    	}
	}
}


/*struct GrainTriangleView_Previews: PreviewProvider {
    static var previews: some View {
		GainTriangleView(readerHeight: , startXOffset: <#T##CGFloat#>, endXOffset: <#T##CGFloat#>, startYHeight: <#T##CGFloat#>, endYHeight: <#T##CGFloat#>, distX: <#T##Double#>, distY: <#T##Double#>)
			
			
			
			/*track: adventureData[0].trackData,
				startIndex: adventureData[0].trackData.trackSummary.mileStats.grade.max.startIndex,
				endIndex: adventureData[0].trackData.trackSummary.mileStats.grade.max.endIndex,
				statData: adventureData[0].trackData.trackSummary.mileStats.grade.max.statData*100,
				stringFormat: "%2.2f%%",
				color: Color.red)*/
    }
}*/
