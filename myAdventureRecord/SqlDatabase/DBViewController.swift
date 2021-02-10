//
//  DBViewController.swift
//  doHikingdbWin
//
//  Created by Robb Mankin on 5/22/18.
//  Copyright © 2018 Robb Mankin. All rights reserved.
//

import Cocoa

class DBViewController: NSViewController {
	
	
	
	let sqlHikingDatabase = SqlHikingDatabase()
	
	/*override func loadView() {
		self.view = NSView()
	}*/
	
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
        		
		dbTableview.delegate = self
		dbTableview.dataSource = self
		//dbTableview.target = self
		dbTableview.doubleAction = #selector(handleDoubleClick)
		//self.createSearchMenu()
		
    }
	
	override func viewWillAppear() {
		super.viewWillAppear()
		dbTableview.reloadData()
	}
	
	// IB Outlets ******************************
 	@IBOutlet weak var dbTableview: NSTableView!
			//	Context Menu Outlets
	@IBOutlet weak var dbContextRetrieve: NSMenuItem!				// menu to retrieve summary information (row(s))
	@IBOutlet weak var dbContextDelete: NSMenuItem!					// menu to delete track information (row(s))
	@IBOutlet weak var dbExportCSV: NSMenuItem!						// menu to export to a csv file track summary information (row*s))
	@IBOutlet weak var dbSearchField: NSSearchFieldCell!			// menu to allow user to search the db using an sqlite query string
	@IBOutlet weak var dbRetrieveDetail: NSMenuItem!				// menu to retrieve track point information from a selected row
	@IBOutlet weak var dbExportJSON: NSMenuItem!
	
	//	IB Actions *****************************
			//	Context Menu Actions
	@IBAction func doRetrieveDetail(_ sender: NSMenuItem) {
			// Retrieve the track point list from a selected row.  Currently that is all the routine does.  This is WIP
			//	as a precurser to building a graphing/charting part of the code
		let tpDB = SqlTrkptsDatabase()								// bring up the track point table
		let trkptList = tpDB.sqlRetrieveTrkptlist(sqlHikingDatabase.tracks[dbTableview.clickedRow].trkIndex)
	}
	@IBAction func doDbContextRetrieve(_ sender: NSMenuItem) {
		//	this function retrieves the track data from the sql database for all selected rows, then individually
		//		passes the data back to theMainViewController for window/view creation and display.  This can be initiated
		//		through either a single/multiple row selection or a double click without selection
		handleDoubleClick()
	}

	@IBAction func doDbSearch(_ sender: NSSearchFieldCell) {		// called when <enter> is pressed in the search box.
		if !sender.stringValue.isEmpty {
			let queryResultRows = sqlHikingDatabase.sqlQueryDb(sender.stringValue)
			sqlHikingDatabase.reloadTracks(someRows: queryResultRows)
		} else {
			sqlHikingDatabase.reloadTracks()
		}
		dbTableview.reloadData()
		self.createSearchMenu()										// add this query to the recent searches list
	}
	
	func createSearchMenu() {
		let menu = NSMenu()
		for i in dbSearchField.recentSearches {
			let theMenuItem = NSMenuItem()
			theMenuItem.title = i
			theMenuItem.target = self
			theMenuItem.action = #selector(changeSearchItem)
			menu.addItem(theMenuItem)
		}
		self.dbSearchField.searchMenuTemplate = menu
	}
	
	@objc func changeSearchItem(sender: AnyObject) {
		// called when the type of search is changed in the search menu.  Probably should set the
		// 	target column search here.
		dbSearchField.title.append(sender.title + "=" )
	}
		
	@objc func handleDoubleClick() {
		// a doubleclick on the mouse will be handled by this routine.  By default a doubleclick
		//	creates the same action as a select and right click on 'retrieve summary' context menuItem
		var selectedRows = Array(dbTableview.selectedRowIndexes)		//  create an array of the selected rows
		selectedRows.append(dbTableview.clickedRow)						//	add the row that the mouse was in when the context
			// 	menu was fired.  this is because the 'clickedRow' may not be highlighted.  I assume that the user will want the
			// 	row that is 'clicked' to be retrieved; if not this line can be removed
		selectedRows = Array(Set(selectedRows))							//	make sure we only handle the unique rows.  Really
			//	here in the case where the user has already	selected the 'clicked' Row, then there will be two entries for
			//	that row
		var tuserInfo = [String:Track]()								//	variable to hold the track 'userInfo' for the notification
		for i in selectedRows {											//	retrieve each record and display
            let trackIdToRetrieve = sqlHikingDatabase.tracks[i].trkIndex
            if let trackretrieved = sqlHikingDatabase.sqlRetrieveRecord(trackIdToRetrieve){
			// 	retrieve the track record.
				tuserInfo["track"] =  trackretrieved
				//	post the notification
				//NotificationCenter.default.post(name: .dbRetrieveNotification, object: MainViewController.self, userInfo: tuserInfo)
			}
		}
	}
	@IBAction func doDbExportJSON(_ sender: NSMenuItem) {
		var selectedRows = Array(dbTableview.selectedRowIndexes)				//  create an array of the selected rows
		selectedRows.append(dbTableview.clickedRow)								//	add the row that the mouse was in when the context menu was fired.  this is because
																				//	the 'clickedRow' may not be highlighted.  I assume that the user will want the row that
																				//	is 'clicked' to be retrieved.  If not this line can be removed
		selectedRows = Array(Set(selectedRows))									//	make sure we only handle the unique rows.  Really here in the case where the user has already
																				//	selected the 'clicked' Row, then there will be two entries for that row
		var tuserInfo = [String:String]()										//	get a variable to hold the track 'userInfo' for the notification
		
		var trackJSONString: String = nullString
		for row in selectedRows {
			if let trackRetrieved = sqlHikingDatabase.sqlRetrieveRecord(sqlHikingDatabase.tracks[row].trkIndex) {
				let trackJSONData = try! JSONEncoder().encode(trackRetrieved)
				if let tempJSONString = String(data: trackJSONData, encoding: .utf8) {
					trackJSONString += tempJSONString
				}
			}
		}
		//print(trackCSVString)
		tuserInfo["json"] = trackJSONString
		//NotificationCenter.default.post(name: .dbRetrieveNotification, object: MainViewController.self, userInfo: tuserInfo)
		
	}
	@IBAction func doDbExportCSV(_ sender: NSMenuItem) {
		
		var selectedRows = Array(dbTableview.selectedRowIndexes)				//  create an array of the selected rows
		selectedRows.append(dbTableview.clickedRow)								//	add the row that the mouse was in when the context menu was fired.  this is because
																				//	the 'clickedRow' may not be highlighted.  I assume that the user will want the row that
																				//	is 'clicked' to be retrieved.  If not this line can be removed
		selectedRows = Array(Set(selectedRows))									//	make sure we only handle the unique rows.  Really here in the case where the user has already
																				//	selected the 'clicked' Row, then there will be two entries for that row
		var tuserInfo = [String:String]()										//	get a variable to hold the track 'userInfo' for the notification
		
		var trackCSVString: String = nullString
		var headerDone: Bool = false
		for row in selectedRows {
			if let trackRetrieved = sqlHikingDatabase.sqlRetrieveRecord(sqlHikingDatabase.tracks[row].trkIndex) {
				if !headerDone {
					trackCSVString = trackRetrieved.exportCSVLine(true)
					//print(trackCSVString)
					headerDone = true
				}
				trackCSVString += String(format: "%3d, ", sqlHikingDatabase.tracks[row].trkIndex) + trackRetrieved.exportCSVLine(false)
				
			}
		}
		//print(trackCSVString)
		tuserInfo["csv"] = trackCSVString
		//NotificationCenter.default.post(name: .dbRetrieveNotification, object: MainViewController.self, userInfo: tuserInfo)
	}
	
	
	
	@IBAction func doDbContextDelete(_ sender: NSMenuItem) {
		var selectedRows = Array(dbTableview.selectedRowIndexes)				//  create an array of the selected rows
		selectedRows.append(dbTableview.clickedRow)								//	add the row that the mouse was in when the context menu was fired.  this is because
																				//	the 'clickedRow' may not be highlighted.  I assume that the user will want the row that
																				//	is 'clicked' to be deleted.  If not this line can be removed
		selectedRows = Array(Set(selectedRows))									//	make sure we only handle the unique rows.  Really here in the case where the user has already
																				//	selected the 'clicked' Row, then there will be two entries for that row
		for i in selectedRows {
			
			let trackIdToDelete = sqlHikingDatabase.tracks[i].trkIndex
			if sqlHikingDatabase.sqlDeleteRecord(trackIdToDelete) {
				print("delete success")
			} else {
				print("delete failed - retry")
			}
		}
		sqlHikingDatabase.reloadTracks()
		dbTableview.reloadData()
		
	}
	
}	// class DBViewController

//****************  Datasource
extension DBViewController: NSTableViewDataSource {
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return sqlHikingDatabase.tracks.count // this needs to be replaced with a function call that returns the number of records in the database
	}
}


//************  Delegate
extension DBViewController: NSTableViewDelegate {
	
	
	
	func twoDecimals(_  theNumber : Double) -> Double {
		return Double(Int(theNumber*100))/100.0
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		let currentTrack = sqlHikingDatabase.tracks[row]						//  currentTrack holds the track data associated with the requested row
		switch tableColumn?.identifier {
		case NSUserInterfaceItemIdentifier(rawValue: "idColumn"):
			let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "idCell")
			guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else {return nil}
			cellView.textField?.integerValue = currentTrack.trkIndex
			return cellView
			
		case NSUserInterfaceItemIdentifier(rawValue: "descriptionColumn"):
			let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "descriptionCell")
			guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else {return nil}
			cellView.textField?.stringValue = currentTrack.header
			return cellView
			
		case NSUserInterfaceItemIdentifier(rawValue: "dateColumn"):
			let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "dateCell")
			guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else {return nil}
			let dateFmt = DateFormatter()
			dateFmt.timeZone = TimeZone.current
			dateFmt.dateFormat =  "MMM dd, yyyy"
			let hikeDate = String(format: "\(dateFmt.string(from: currentTrack.trackSummary.startTime!))")
			cellView.textField?.stringValue = hikeDate
			return cellView
			
		case NSUserInterfaceItemIdentifier(rawValue: "distanceColumn"):
			let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "distanceCell")
			guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else {return nil}
			cellView.textField?.doubleValue = twoDecimals(currentTrack.trackSummary.distance/metersperMile)
			return cellView
			
		case NSUserInterfaceItemIdentifier(rawValue: "durationColumn"):
			let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "durationCell")
			guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else {return nil}
			cellView.textField?.doubleValue = twoDecimals(currentTrack.trackSummary.duration / secondsperHour)
			return cellView
			
		case NSUserInterfaceItemIdentifier(rawValue: "elevationColumn"):
			let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "elevationCell")
			guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else {return nil}
			cellView.textField?.doubleValue = twoDecimals(currentTrack.trackSummary.elevationStats.max.elevation * feetperMeter)
			return cellView
			
		case NSUserInterfaceItemIdentifier(rawValue: "ascentColumn"):
			let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ascentCell")
			guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else {return nil}
			cellView.textField?.doubleValue = twoDecimals(currentTrack.trackSummary.totalAscent * feetperMeter)
			return cellView
			
		case NSUserInterfaceItemIdentifier(rawValue: "descentColumn"):
			let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "descentCell")
			guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else {return nil}
			cellView.textField?.doubleValue = -twoDecimals(currentTrack.trackSummary.totalDescent * feetperMeter)
			return cellView
			
		case NSUserInterfaceItemIdentifier(rawValue: "speedColumn"):
			let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "speedCell")
			guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else {return nil}
			cellView.textField?.doubleValue = twoDecimals(currentTrack.trackSummary.avgSpeed * (secondsperHour/metersperMile))
			return cellView
			
		case NSUserInterfaceItemIdentifier(rawValue: "commentColumn"):
			let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "commentCell")
			guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else {return nil}
			cellView.textField?.stringValue = "none"
			return cellView
			
		default:
			if let tableColumnIdentifier = tableColumn?.identifier {
				print("Oops unknown column in tableView - \(tableColumnIdentifier)")
			} else {
				print("Oops unknown column in tableView - nil")
			}
			return nil
		}
	}
	
	func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
		//print("sortdescriptors did change")
		let sortDescriptors = dbTableview.sortDescriptors
		switch sortDescriptors[0].key {
		case "descriptionSort" :
			if sortDescriptors[0].ascending {
				sqlHikingDatabase.tracks.sort(by: {$0.header >= $1.header})
			} else {
				sqlHikingDatabase.tracks.sort(by: {$0.header < $1.header})
			}
		case "dateSort" :
			if sortDescriptors[0].ascending {
				sqlHikingDatabase.tracks.sort(by: {$0.trackSummary.startTime! >= $1.trackSummary.startTime!})
			} else {
				sqlHikingDatabase.tracks.sort(by: {$0.trackSummary.startTime! < $1.trackSummary.startTime!})
			}
		case "distanceSort" :
			if sortDescriptors[0].ascending {
				sqlHikingDatabase.tracks.sort(by: {$0.trackSummary.distance >= $1.trackSummary.distance})
			} else {
				sqlHikingDatabase.tracks.sort(by: {$0.trackSummary.distance < $1.trackSummary.distance})
			}
		
		case "durationSOrt" :
			if sortDescriptors[0].ascending {
				sqlHikingDatabase.tracks.sort(by: {$0.trackSummary.duration >= $1.trackSummary.duration})
			} else {
				sqlHikingDatabase.tracks.sort(by: {$0.trackSummary.duration < $1.trackSummary.duration})
			}
		case "elevationSort" :
			if sortDescriptors[0].ascending {
				sqlHikingDatabase.tracks.sort(by: {$0.trackSummary.elevationStats.max.elevation >= $1.trackSummary.elevationStats.max.elevation})
			} else {
				sqlHikingDatabase.tracks.sort(by: {$0.trackSummary.elevationStats.max.elevation < $1.trackSummary.elevationStats.max.elevation})
			}
		case "ascentSort" :
			if sortDescriptors[0].ascending {
				sqlHikingDatabase.tracks.sort(by: {$0.trackSummary.totalAscent >= $1.trackSummary.totalAscent})
			} else {
				sqlHikingDatabase.tracks.sort(by: {$0.trackSummary.totalAscent < $1.trackSummary.totalAscent})
			}
		case "descentSort" :
			if sortDescriptors[0].ascending {
				sqlHikingDatabase.tracks.sort(by: {$0.trackSummary.totalDescent >= $1.trackSummary.totalDescent})
			} else {
				sqlHikingDatabase.tracks.sort(by: {$0.trackSummary.totalDescent < $1.trackSummary.totalDescent})
			}
		case "speedSort" :
			if sortDescriptors[0].ascending {
				sqlHikingDatabase.tracks.sort(by: {$0.trackSummary.avgSpeed >= $1.trackSummary.avgSpeed})
			} else {
				sqlHikingDatabase.tracks.sort(by: {$0.trackSummary.avgSpeed < $1.trackSummary.avgSpeed})
			}
		default:
			if sortDescriptors[0].ascending {
				sqlHikingDatabase.tracks.sort(by: {$0.trkIndex >= $1.trkIndex})
			} else {
				sqlHikingDatabase.tracks.sort(by: {$0.trkIndex < $1.trkIndex})
			}
		}
		
				
		dbTableview.reloadData()
		
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		//sqlHikingDatabase.retrieveRecord()
		let selectedIndexes = Array(dbTableview.selectedRowIndexes)
		//print("selection did change ")
        if !selectedIndexes.isEmpty {
            print("last selected row \(selectedIndexes[0])")
        }
	}
	
	
}
