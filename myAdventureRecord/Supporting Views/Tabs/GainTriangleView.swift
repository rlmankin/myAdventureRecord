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
	
	var color: Color
	
	
	
    var body: some View {
		
		let frameHeight = CGFloat(50.0)
		GeometryReader { reader in
			Path { p in
				p.move( to: CGPoint(x: startXOffset, y: readerHeight - startYHeight))
				p.addLine( to: CGPoint(x: endXOffset, y: readerHeight - startYHeight))
				p.addLine(to: CGPoint(x: endXOffset, y: readerHeight - endYHeight))
			}.stroke(color, style: StrokeStyle(dash: [2]))
			 .offset(x:30, y:0)
			
			
			
			
    	}
	}
}

//  No preview for this view, must use upper level preview from MinMaxChart.
/*struct GrainTriangleView_Previews: PreviewProvider {
    static var previews: some View {
		GeometryReader { reader in
			GainTriangleView(readerHeight: reader.size.height, startXOffset: <#T##CGFloat#>, endXOffset: <#T##CGFloat#>, startYHeight: <#T##CGFloat#>, endYHeight: , color: <#Color#>)
			
		}
    }
}*/
