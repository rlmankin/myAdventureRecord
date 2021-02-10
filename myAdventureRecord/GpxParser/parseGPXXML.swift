//
//  parseGPXXML.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 2/10/21.
//

//  This is the 'guts' of the hikingdbWin program.  This class parse a .gpx file to create a set of points
//		to be used to determine various track statistics.  This was heavily leveraged from a python version
//		This uses the Foundation capability to read XML

//	This file was copy/pasted from doHikingDb.  I did this in order to remove the dependencies of a documented-based app (like doHikingDbWin)
//		to a SwiftUI framework.  Assumption is to remove all document based elements and replace with an 'appropriate' SwiftUI construct
import Foundation
import CoreLocation

class parseGPXXML: NSObject, XMLParserDelegate {
	
	
	
	var numCalls : Int								// Dictionary that contains the overall summary stats of the track
	var currentTrackIndex : Int
	var currentTrkptIndex : Int
	var lastTrkptIndex	: Int
	var lastValidTrkptElevationIndex : Int			// The index of the most recent trackpoint to have a valid elevation property
	var lastValidTrkptTimestampIndex : Int			// The index of the most recent trackpoint to have a valid timestamp/
	var lastValidEleAndTimeIndex : Int				// The index of the most recent trackpoint to have BOTH a valid elevation & valid timestamp
	var fcShouldExpect : String
	var elementsBeingProcessed = ElementProcessingState(value:false)
	var currentTrack = Track()
	var allTracks = [Track]()
	var currentTrkpt = Trkpt()
	var parentViewController: MainViewController		// this causes a Runtime warning about this not being in the Main Thread.  Not sure what
													//	to do about it yet
	var parseURL: URL
	var gpxDocumentArray = [Document]()											// holds the documents created when a track is found
	
	
	
	override init() {
		self.numCalls = 0
		self.fcShouldExpect = nullString
		self.currentTrackIndex = 0
		self.currentTrkptIndex = 0
		self.lastTrkptIndex = -1
		self.lastValidTrkptElevationIndex = -1
		self.lastValidTrkptTimestampIndex = -1
		self.lastValidEleAndTimeIndex = -1
		self.parentViewController = MainViewController()
		self.parseURL = URL(string: "blah")!
		super.init()
	}
	
	func parseURL( gpxURL: URL, parentViewController: MainViewController) {
		self.parentViewController = parentViewController	// this is where the runtime warning occurs.  Just dispathqueue the progress bar update?
		parseURL = gpxURL
		let gpxParser = XMLParser(contentsOf: gpxURL)!
		gpxParser.delegate = self
		gpxParser.shouldReportNamespacePrefixes = true
		gpxParser.shouldProcessNamespaces = true
		
			//let parserSuccess = gpxParser.parse()
		if !gpxParser.parse() {
				// Parser Error
				print("XML parsing failed at \(gpxParser.lineNumber):\(gpxParser.columnNumber) \nDebug Description: \(gpxParser.debugDescription)")
		}
	}
	
	private func processElement(elementName: String,
								qName: String?,
								attributes: [String:String])  {					// processElement is only called with 'other' elementNames
		
		if  elementsBeingProcessed.trk &&
			!elementsBeingProcessed.trkSeg &&
			garminSummaryStats.contains(elementName) {
				currentTrack.garminSummaryStats[elementName] = "waitingforfoundCharacters"		//  Should be in the Summary area of the xml (i.e. trk && !trkSeg
				fcShouldExpect = elementName
				//print(elementName)
		}
		
		if elementsBeingProcessed.trk &&
			elementsBeingProcessed.trkSeg &&
			elementsBeingProcessed.trkpt {
																				// get the latitude, ongitude, time, and elevation.  The closure are simply for safety.
																				//	the only elements currently tracks are trackpoint, routepoint, elevation, and time
																				//	These values should always be available unless the garmin gpx is not properly formed
			
			switch elementName {
				//	The handling of trackpoints and route points is different that elevation and time.  In the garmin .gpx format the latitude and longitude are
				// 		labeled with 'lat =' and 'long ='
			case "trkpt", "rtept":
				

				if let tempVar = attributes["lat"] {
					currentTrkpt.latitude = Double(tempVar)!					// Can safely forceunwrap because if there is a latitude garmin will ensure it is properly formed
				}
				if let tempVar = attributes["lon"] {
					currentTrkpt.longitude = Double(tempVar)!					// safe to unwrap for same reason latitude is safe
				}
			case "ele":
				fcShouldExpect = elementName
			case "time":
				fcShouldExpect = elementName
			default :
				break															// do nothing
			}
		}
	}
	
	
	
	func parserDidStartDocument(_ parser: XMLParser) {
		print("xml parsing started: \(parseURL.absoluteString.removingPercentEncoding ?? "")")
	}
	
	func parserDidEndDocument(_ parser: XMLParser) {

		print("xml parsing reached end of document")
	}
	
	//	Process Starting Elements.  Those with a < elementName> XML tag  ********************************************
	func parser(_ parser: XMLParser,
				didStartElement elementName: String,
				namespaceURI: String?,
				qualifiedName qName: String?,
				attributes: [String : String])   {
		numCalls += 1										// Keep track of how many times didStartElement has been called
		switch elementName {
			case "trk", "rte" :		// a <trk> tag currently frames a single track recording.  It is generally composed of one or more
								// 	<trkseg> tags (although to date I have only seen a single <trkseg>.
				
					// to implement early window creation I need to find a way to signal the ?mainViewController? to create a
					// document at this time
				elementsBeingProcessed.trk = true								// set track processing flag
				currentTrackIndex += 1											// increment the local track ID
				currentTrack.trkIndex = currentTrackIndex								// set the current track's id
				currentTrack.trackURLString = self.parseURL.absoluteString		// set the current track's URL to the URL passed in to init
				currentTrkptIndex = -1											// new track starts a new sequence of trackpoints
				lastValidTrkptTimestampIndex = -1
				lastValidTrkptElevationIndex = -1
				lastValidEleAndTimeIndex = -1
				lastTrkptIndex = -1
					
			case "trkseg" :		// a <trkseg> tag currently frames a set of <trkpt> tags.  To date, I have only seen a single <trkseg>
								//	with no extra data provided unique to the <trkseg>.  Therefore, do nothing with this tag
				elementsBeingProcessed.trkSeg = true							// set track segment processing flag
			
			case "trkpt", "rtept":		// a <trkpt> tag defines a specific waypoint in the track.  It is composed of string for latitude "lat",
								//	and longitude "lon".  There will be two followup optional tags <ele> for elevation and <time> for a date/time stamp
								// 	Since <ele> and <time> are not StartElements they will generate "FoundCharacters" events and processed in
								//	that function
				elementsBeingProcessed.trkpt = true								// set track point processing flag
				
				currentTrkptIndex += 1											// increment the trackpoint index being worked on
				currentTrkpt.index = currentTrkptIndex							// set the trackpoint index property
				currentTrkpt.hasValidElevation = false							// with a new trackpoint clear the valid elevation flag
				currentTrkpt.hasValidElevation = false							// and the valid timestamp flag
				processElement(elementName: elementName, qName: qName, attributes: attributes)
			
			case "ele" :		// "ele" tags a piece of elevation data
				elementsBeingProcessed.other = true
				processElement(elementName: elementName, qName: qName, attributes: attributes)
			case "time" :		// "time" tags a timeStamp
				elementsBeingProcessed.other = true
				processElement(elementName: elementName, qName: qName, attributes: attributes)
			default :			// at this point all other Elements are passed to processElement for unique handling.  In general, unique
								// 	handling will be to determined by the "elementsBeingProcessed" state.
				elementsBeingProcessed.other = true
				processElement(elementName: elementName, qName: qName, attributes: attributes)
		}
		/*print("\n\ndidStartElement Calls > \(numCalls)")
		print("didStartElement: \(elementName)")
		print("namespaceURI: \(namespaceURI!)")
		print("qualifiedName: \(qName!)")
		for (key, value) in attributes {
			//let x = attributes[key]
			print("[\(key)::\n\t\(value)]")
		}*/
		
		
	}
	
	func populateTrkptStructures() {											// Once all tags associated with the active trackpoint have been parsed this method
																				// 	will populate the full trackpoint structure
		
		
		if currentTrkpt.index > 0 {
			//	populate lastTrkpt structure (index, distance)
			currentTrkpt.lastTrkpt.lastValidIndex = currentTrkpt.index - 1			//	the last trackpoint is the previous trackpoint in the current track
			currentTrkpt.lastTrkpt.distance = calcDistance(currentTrkpt,
															currentTrack.trkptsList[currentTrkpt.lastTrkpt.lastValidIndex])
		}
		if lastValidTrkptTimestampIndex >= 0 {
			// Calculate the distance between the current trackpoint and the previous one
			//	populate lastDistTrkpt structure (index, distance, elapsedTime... travelSpeed is a get-only property)
			currentTrkpt.lastTimeDistTrkpt.lastValidIndex = lastValidTrkptTimestampIndex
			currentTrkpt.lastTimeDistTrkpt.distance = calcDistance(currentTrkpt,
																   currentTrack.trkptsList[currentTrkpt.lastTimeDistTrkpt.lastValidIndex])
			currentTrkpt.lastTimeDistTrkpt.elapsedTime = calcElapsedTime(currentTrkpt,
																	 currentTrack.trkptsList[currentTrkpt.lastTimeDistTrkpt.lastValidIndex])
																			// trailSpeed is a get-only property
		}
		if lastValidEleAndTimeIndex >= 0 {
			//	populate lastTimeEleTrkpt structure (index, gain, elapsedtime...  gainSpeed is a get-only property
			currentTrkpt.lastTimeEleTrkpt.lastValidIndex = lastValidEleAndTimeIndex
		
			if let elevationGain = calcGain(currentTrkpt,
											currentTrack.trkptsList[currentTrkpt.lastTimeEleTrkpt.lastValidIndex]) {
				currentTrkpt.lastTimeEleTrkpt.gain = elevationGain
			}
			currentTrkpt.lastTimeEleTrkpt.elapsedTime = calcElapsedTime(currentTrkpt,
																	 currentTrack.trkptsList[currentTrkpt.lastTimeEleTrkpt.lastValidIndex])
			currentTrkpt.lastTimeEleTrkpt.distance = calcDistance(currentTrkpt, currentTrack.trkptsList[currentTrkpt.lastTimeEleTrkpt.lastValidIndex])
		}
		
		if lastValidTrkptElevationIndex >= 0 {
			currentTrkpt.lastEleTrkpt.lastValidIndex = lastValidTrkptElevationIndex
			currentTrkpt.lastEleTrkpt.distance = calcDistance(currentTrkpt, currentTrack.trkptsList[currentTrkpt.lastEleTrkpt.lastValidIndex])
			if let elevationGain = calcGain(currentTrkpt, currentTrack.trkptsList[currentTrkpt.lastEleTrkpt.lastValidIndex]) {
				currentTrkpt.lastEleTrkpt.gain = elevationGain
			}
			
		}
		
		
		switch (currentTrkpt.hasValidElevation, currentTrkpt.hasValidTimeStamp) {
		case (false, true) :
			//print("have no elevation, but have timestamp")
			lastValidTrkptTimestampIndex = currentTrkpt.index
		case (true, false) :
			//print("have elevation, but no timestamp")
			lastValidTrkptElevationIndex = currentTrkpt.index
		case (true, true) :
			//print("have both elevation & timestamp")
			lastValidTrkptElevationIndex = currentTrkpt.index
			lastValidTrkptTimestampIndex = currentTrkpt.index
			lastValidEleAndTimeIndex = currentTrkpt.index
		default:
			//print("have no elevation AND no timestamp")
			break																// legal way to 'do nothing'
		}
	}
	
	
	
		// Process information that is not captured by a "xxx=" label (e.g. lat= or lon=.  In current (11/6/2019) version this is only capturing elevation (ele) and/timestamp (time)
	func parser(_ parser: XMLParser, foundCharacters: String) {
		if elementsBeingProcessed.trk && !elementsBeingProcessed.trkSeg && fcShouldExpect != nullString {
			// A /<trk> tag has been found but not a /<trkseg> tag, meaning we are in the header portion of the track information.  If I've found
			// 	a "name" tag then create a document and a view controller  to display and hold the track information.  This insures I have the
			//	necessary UI objects ready.
			
			currentTrack.garminSummaryStats[fcShouldExpect] = foundCharacters
			if fcShouldExpect == "name" {
				
				
				
				DispatchQueue.main.async {
					if MainViewController.firstGPXParse {
						let gpxSummaryDocument = self.parentViewController.view.window?.windowController?.document as! Document
						let viewController = gpxSummaryDocument.windowControllers[0].contentViewController as! MainViewController
						viewController.textView.string = "Working ..."										// output the results to the view
						viewController.view.window?.title = foundCharacters
						//print("appending gpxSummaryDocument \(gpxSummaryDocument), firstparse", self.parentViewController.isViewLoaded)
						self.gpxDocumentArray.append(gpxSummaryDocument)
						MainViewController.firstGPXParse = false
					} else {
						do {
							let gpxSummaryDocument = try documentController.openUntitledDocumentAndDisplay(true) as! Document
							let viewController = gpxSummaryDocument.windowControllers[0].contentViewController as! MainViewController
							viewController.textView.string = "Working ..."										// output the results to the view
							viewController.view.window?.title = foundCharacters
							print("appending gpxSummaryDocument \(gpxSummaryDocument), not firstparse")
							self.gpxDocumentArray.append(gpxSummaryDocument)
						} catch let error as NSError {						// if the documentController doesn't have a window or document the abort
							self.parentViewController.doHikingDbAlert(message: "open failed \(error), file: \(self.parseURL.absoluteString)")
						//fatalError("open failed \(error), file: \(filesArray[i])")
						}
					}
				}
			}
			fcShouldExpect = nullString
		}
		
		if elementsBeingProcessed.trk &&
			elementsBeingProcessed.trkSeg &&
			elementsBeingProcessed.trkpt {
			switch fcShouldExpect {
			case "ele" :
				if let tmpInt = Double(foundCharacters) {
					currentTrkpt.elevation = tmpInt
				}
			case "time":
				// Set date format
				let dateFmt = DateFormatter()
				dateFmt.timeZone = TimeZone(abbreviation: "GMT")
				dateFmt.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss'Z'"
				let date =  dateFmt.date(from:foundCharacters)
				if let tmpdate = date {
					currentTrkpt.timeStamp = tmpdate
				} else {
					break
					//print("unexpected foundCharacters in 'time' '\(foundCharacters)'")
				}
			default :
				print("unexpected characters in '\(fcShouldExpect)': '\(foundCharacters)'")
			}
		}
		//print("foundCharacters: '\(foundCharacters)'")
	}
	
		// Process End Elements.  Those with a < /elementName> XML tag  ************************************************
	func parser(_ parser: XMLParser,
				didEndElement elementName: String,
				namespaceURI: String?,
				qualifiedName qName: String?) {
		switch elementName {
		case "trk", "rte" :			// Encounterd the </trk> tag indicating end of the track.  Move all the various information gathered into
								//	the currentTrack structure and change the state of elementsBeingProcessed.
					// This is also the time to generate all the tracks vital statistics
						
			if let tempname = currentTrack.garminSummaryStats["name"] {						// put the track name into the track header
				currentTrack.header = tempname
				if tempname.contains("\n") {
					currentTrack.header = " "
				}
			}
			//print(currentTrack.trkptsList.count)

			calculateTrkProperties(&currentTrack)								//  calculate all the track properties that do not rely on specific mileage informaton
			//print("examining gpxDocumentArray \(gpxDocumentArray)")
			createMileageStats(&self.currentTrack, gpxDocumentArray.last)		//  create all the track properties that require information regarding mileage.
																				//	in the case of near empty or very small .gpx files gpxDocumentArray may not have yet
																				//	been populated yet from the earlier dispatchQueue.  In that case createMileageStats will
																				//	not attempt to update the window progress bar
			/*if let validgpxDocument = gpxDocumentArray.last {
				createMileageStats(&self.currentTrack, validgpxDocument)		//  create all the track properties that require information regarding mileage.
																				//	pass validegpxDocument to enable progress bar is updated.  Really only need viewController
			} else {
				self.parentViewController.doHikingDbAlert(message: "createMileageStats called with nil Document")
			}*/
			allTracks.append(currentTrack)										//	add the current track to the all tracks array
			
			
			//currentTrack.print()

			currentTrack.clean()												// 	clean up and empty the current track variable
			elementsBeingProcessed.trk = false									// 	since we're done, clear processing flag
		case "trkseg" :
			elementsBeingProcessed.trkSeg = false
		case "trkpt", "rtept" :
			//  when the trkpt/rtept end tag is processed the currentTrkpt can only be guaranteed to have .index, .latitude, and .longitude populated
			//		it may have .elevation and .timeStamp populated as well.  It is now time to populate the remainder of the trackpoint structure
			//	To fully populate the trackpoint I need to know the last valid elevation trackpoint index and the last valid distance trackpoint index.
			//	The question is "where to I set those variables?
			
			populateTrkptStructures()
			updateLastValidIndexPointers()
			currentTrack.trkptsList.append(currentTrkpt)						// 	add the current trackpoint to the track point lis
			currentTrkpt = .init()												//	clean up and empty the current track point variable
			elementsBeingProcessed.trkpt = false
		case "ele" :															// a </ele> tag has been found, now post process the appropriate elevation properties, if any
			currentTrkpt.hasValidElevation = true								// set the valid elevation flag to let the end trackpoint </trkpt> process know there was a
																				//		valid elevation found
			elementsBeingProcessed.other = false
		case "time" :															// a </time> tag has been found, now post process the appropriate timestamp properties, if any
			currentTrkpt.hasValidTimeStamp = true											// set the valid timestamp flag to let the end trackpoint prodess know there was a valide timestamp
			elementsBeingProcessed.other = false
		default :
			elementsBeingProcessed.other = false
			// if the elementName is "name" then I know I have a track name and could populate the document title with the name of the track
		}
		
		/*//print("didEndElement Calls > \(numCalls)")
		print("didEndElement: \(elementName)")
		//print("namespaceURI: \(namespaceURI!)")
		print("qualifiedName: \(qName!)\n\n")*/
		
	}
	
	func updateLastValidIndexPointers () {
		
	}
	
	
}

