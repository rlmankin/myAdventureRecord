//
//  GlobalConstants.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/6/20.
//

import Foundation
import SwiftUI

let nullString = ""
let metersperMile = 1609.344
let feetperMeter = 3.280839895
let secondsperHour = 3600.0

let garminSummaryStats = ["name", "Distance", "TimerTime",  "TotalElapsedTime",
						  "MovingTime", "StoppedTime", "MovingSpeed",
						  "MaxSpeed", "MaxElevation", "MinElevation",
						  "Ascent", "Descent","AvgAscentRate",
						  "MaxAscentRate", "AvgDescentRate","MaxDescentRate",
						  "Calories"]
// helper functions
// elevation related helpers
func elevationHeight( _ height: CGFloat, _ maxEle : Double, _ minEle : Double) -> CGFloat {
			// calculated  grid distance for the height of the graph
			// Note:  the trkptList array global to the structure
			//	<pixel>/<unit of elevation>
	
	return height / CGFloat(abs(maxEle - minEle))
			// determine the spacing by dividing the total height of the
			//		drawing area by the range of elevations
}

func elevationOffset(_ elevation: Double, _ axisheight: CGFloat, _ minEle : Double) -> CGFloat {
			// determines where in the vertical axis a particular elevation will reside
			//	lower bound (bottom) is offset by the minimum Elevation in the track
			// 	elevation is the elevation to be plotted, axisHeight is the number of pixels
			//	on the vertical axis
	return CGFloat(elevation - minEle) * axisheight		// number of feet
}

func createEleGridPoints( minEle: Double, maxEle: Double, stepSize: Double) -> [Double] {
	var eleGridline : [Double] = []
	var i = minEle
	while ( i <= maxEle) {
		eleGridline.append(i)
		i += Double(stepSize)
	}
	return eleGridline
}

// distance related helpers
func distanceWidth(_ width: CGFloat, _ totalDistance : Double) -> CGFloat {
			// calculated horizontal grid size for the distance of the track
			//	(pixel/<unit distance>
	
	return width / CGFloat(totalDistance)
}

func distanceOffset(_ legDistance: Double, axisWidth: CGFloat) -> CGFloat {
	let legOffset = (legDistance) * Double(axisWidth)
	//print("legOffset[\(distanceIndex)] = \(legDistance),  / \(totalDistance) = \(legOffset), axisWidth \(Double(axisWidth))")
	return CGFloat(legOffset)
}

/*func calcLegDistance(_ index: Int) -> Double {
	return self.track.trkptsList[...index].compactMap({$0.lastTrkpt.distance}).reduce(0,+)	}
*/
//	misc helpers



func roundUptoNearest( nearest: Double, _ x : Double) -> Double {
	return ceil(Double(nearest) * Double(Int(x/Double(nearest)) + 1))
}
func roundDowntoNearest( nearest: Double, _ x : Double) -> Double {
	return floor(Double(nearest) * Double(Int(x/Double(nearest))))
}



struct ReturnStruct {
	enum parseProgress {
		case notStarted
		case inProgress
		case done
	}
	
	
	var url: URL
	var parseThis : Bool
	var creationDate: Date
	var parseInProgress = parseProgress.notStarted
	var color: Color {
		get {
			switch parseInProgress {
				case .notStarted : return Color.white
				case .inProgress : return Color.yellow
				case .done : return Color.green
			}
		}
	}
	var numTracks : Int = 0
	var numTrkpts : [Int] = []
	var trackRow : [Int] = []
	var trkptRow : [Int] = []
	
	mutating func clean() {
		numTracks = 0
		numTrkpts = []
		trackRow  = []
		trkptRow  = []
	}
	
	
}
