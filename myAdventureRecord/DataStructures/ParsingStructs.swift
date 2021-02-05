//
//  ParsingStructs.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 12/6/20.
//

import Foundation

struct ElementProcessingState {													// Structure to be used as a state variable in the GPX parser delegate to know what tags are being processed
	var trk : Bool
	var trkSeg : Bool
	var trkpt : Bool
	var other : Bool
	
	init(value: Bool) {
		trk = value
		trkSeg = value
		trkpt = value
		other = value
	}
}
