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
extension Date {

	static func - (lhs: Date, rhs: Date) -> TimeInterval {
		return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
	}

}
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

func distanceOffset(_ legDistance: Double, pixelPerMeter: CGFloat) -> CGFloat {
	// distance from axis origin to the pixel position corresponding to the distance (e.g. 1000 m * (0.05 pixel/m) = 50 pixel position
	let legOffset = (legDistance) * Double(pixelPerMeter)
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
	var trackdbRow : [Int] = []
	var advdbRow : [Int] = []
	
	mutating func clean() {
		numTracks = 0
		numTrkpts = []
		trackdbRow  = []
		advdbRow  = []
	}
	
	
}

import IOKit.pwr_mgt

var noSleepAssertionID: IOPMAssertionID = 0
var noSleepReturn: IOReturn? // Could probably be replaced by a boolean value, for example 'isBlockingSleep', just make sure 'IOPMAssertionRelease' doesn't get called, if 'IOPMAssertionCreateWithName' failed.

func disableScreenSleep(reason: String = "Unknown reason") -> Bool? {
	guard noSleepReturn == nil else { return nil }
	noSleepReturn = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString,
											IOPMAssertionLevel(kIOPMAssertionLevelOn),
											reason as CFString,
											&noSleepAssertionID)
	return noSleepReturn == kIOReturnSuccess
}

func  enableScreenSleep() -> Bool {
	if noSleepReturn != nil {
		_ = IOPMAssertionRelease(noSleepAssertionID) == kIOReturnSuccess
		noSleepReturn = nil
		return true
	}
	return false
}

func timeStampLog(message: String, noPrint: Bool = false) -> Void {
	let now = Date()
	let df = DateFormatter()
	df.dateFormat = "yyyyMMddd HH:mm:ss.SS"
	if !noPrint {
		print("\(df.string(from: now)) :  \(message)")
	}
	return //now
}

func timeDiff(lhs : Date, rhs : Date ) -> Double {
	return lhs - rhs
}

func xlocationInPixels(x: Double, chartWidthInPixels : CGFloat, xRange : Double, min: Double) -> CGFloat {
	let leftEdgeX : CGFloat = CGFloat(min)
	let xToPixelRatio : CGFloat = chartWidthInPixels / CGFloat(xRange)
	//let returnValue = (x - leftEdgeX) * xToPixelRatio
	return (CGFloat(x) - leftEdgeX) * xToPixelRatio
}

func ylocationInPixels( y: Double, chartHeightinPixels: CGFloat, yRange: Double) -> CGFloat {
	return chartHeightinPixels - (CGFloat(y) * (chartHeightinPixels / CGFloat(yRange)))
}

