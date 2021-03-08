//
//  SqlTrkPtsDatabase.swift
//  doHikingdbWin
//
//  Created by Robb Mankin on 11/9/20.
//  Copyright © 2020 Robb Mankin. All rights reserved.
//


import Cocoa
import SQLite

class SqlTrkptsDatabase: NSObject {
	var sqltpDbURL : URL
	var sqltpDbTable : TrkptsSqlTable
	var sqltpDbFileHandle : Connection?
	let sqltpDbName : String = "/hikingdb.sqlite"
	let sqltpDbTableName : String = "tpdbTable"
	
	var trkpts = [Trkpt]()
	
	override init() {
		self.sqltpDbURL = URL(string:sqltpDbName)!				//  initialize to the sql database name
		self.sqltpDbTable = TrkptsSqlTable()					//	create the database table
		self.sqltpDbFileHandle = nil							//	init the file handle to nil
		super.init()
		
		if self.sqlConnectOpenDb() {
			//print("TrkptDB opened successfully in init")
		} else {
			print("TrkptDB open failed in init")
		}
	}
	
	func sqlConnectOpenDb() -> Bool {
		let trkptsDb = self
		let dbFilePathString = trkptsDb.getSqlDbFilePath()		// get the path to where the sql database is stored
		if dbFilePathString != nil {
			if let tempDbFileHandle = trkptsDb.sqlDbConnect("\(dbFilePathString! + sqltpDbName)") {
				// try and form a connection to the sql database returns a Connction?
				//print("\(dbFilePathString! + sqltpDbName) connected")
				sqltpDbFileHandle = tempDbFileHandle
				return trkptsDb.sqlCreateTpTable()
				// create the dbTable, returns Bool (true if table correctly created)
			} else {
				return false
			}
		} else {
			print("Error in track point database string creation")
			return false
		}
	}
	
	func getSqlDbFilePath() -> String? {
	// Return a string with the path to the default dB found in Bundle.main.bundleIdentifier.
		let dbFileString = NSSearchPathForDirectoriesInDomains(
			// find the appropriate location for the sql database (per Apple requriements).  The creation and open
			// of the database will NOT succeed if given an arbitrary path.  Not sure why, think it has something to do with sandbox.
				.documentDirectory, .userDomainMask, true
			).first! + "/hiking/hikingDatabase"
		// create parent directory iff it doesn’t exist
		do {
			try FileManager.default.createDirectory(
				atPath: dbFileString, withIntermediateDirectories: true, attributes: nil)
				return dbFileString
		} catch {
			Swift.print("path creation issue?  Error: \(error)")
			return nil
		}
	}
	
	func sqlDbConnect(_ databaseString: String) -> Connection? {					// databaseString contains the absolute path to the hiking sql database
		do {
			let sqlFilehandle = try Connection(databaseString)					// see if a connection can be made to the sql database.
																				//	'Connection' will create a database if there is not one
			//Swift.print("Connection to \(databaseString) succeeded")
			return sqlFilehandle
		} catch {																// the connection to the hiking sql database can't be made.  Hopefully 'error' will tell why.
			Swift.print("Connection to \(databaseString) failed.  Error: \(error)")
			return nil
		}
	}
	
	
	struct TrkptsSqlTable {			// track points database table, should mirror trkpt structure
									//	plus some overhead for links to corresponding track structure
		
		
		var sqltpUniqueID = Expression<Int>("tpuniqueID")
		
		// Link to track of which this track point is a member.  Use the sqlUniqueID
		var sqltpTrkID = Expression<Int>("trkptTrackID")
		
		// Flat representation of structures within TrkPt
		
		// mirror of FromValidEleTime  structure in Trkpt structure
		//	use acronym FVET to correspond to FromValidEleTime
		var sqlFVETlastValidIndex = Expression<Int>("FVETlastValidIndex")
		var sqlFVETdistance = Expression<Double>("FVETdistance")
		var sqlFVETgain = Expression<Double>("FVETgain")
		var sqlFVETelapsedTime = Expression<Double>("FVETelapsedTime")
		
		// mirror of FromValidDistTime  structure in Trkpt structure
		//	use acronym FVDT to correspond to FromValidDistTime
		var sqlFVDTlastValidIndex = Expression<Int>("FVDTlastValidIndex")
		var sqlFVDTdistance = Expression<Double>("FVDTdistance")
		var sqlFVDTelapsedTime = Expression<Double>("FVDTelapsedTime")
		
		// mirror of FromValidEleTrkPt  structure in Trkpt structure
		//	use acronym FVETp to correspond to FromValidEleTrkPt
		var sqlFVETplastValidIndex = Expression<Int>("FVETplastValidIndex")
		var sqlFVETpdistance = Expression<Double>("FVETpdistance")
		var sqlFVETpgain = Expression<Double>("FVETpgain")
		var sqlFVETpelapsedTime = Expression<Double>("FVETpelapsedTime")
		
		
		// mirror of FromLastTrkPt  structure in Trkpt structure
		//	use acronym FLTp to correspond to FromLastTrkPt
		var sqlFLTplastValidIndex = Expression<Int>("FLTplastValidIndex")
		var sqlFLTpdistance = Expression<Double>("FLTpdistance")
		var sqlFLTpgain = Expression<Double>("FLTpgain")
		
		// mirror of StatisticsTrkPt  structure in Trkpt structure
		//	use acronym STp to correspond to StatisticsTrkPt
		var sqlSTplastValidIndex = Expression<Int>("STplastValidIndex")
		var sqlSTpdistance = Expression<Double>("STpdistance")
		var sqlSTpgain = Expression<Double>("STpgain")
		var sqlSTpelapsedTime = Expression<Double>("STpelapsedTime")
		
		// mirror properties of TrkPt
		//	use acronym Tp to correspond to TrkPt (help distinguish from Track properties
		var sqlIndex = Expression<Int>("TpIndex")
		var sqlHasValidElevation = Expression<Bool>("TphasValidElevation")
		var sqlHasValidTimeStamp = Expression<Bool>("TphasValidTimeStamp")
		var sqlLatitude = Expression<Double>("Tplatitude")
		var sqlLongitude = Expression<Double>("Tplongitude")
		var sqlElevation = Expression<Double?>("Tpelevation")
		var sqlTimeStamp = Expression<Date?>("TptimeStamp")
		
		// property lastTimeEleTrkpt mirrored in sqlFVET psuedoStruct (above)
		// property lastTimeDistTrkpt mirrored in sqlFVDT psuedoStruct (above)
		// property lastEleTrkpt mirrored in sqlFEDTp psuedoStruct (above)
		// property lastTrkpt mirrored in sqlFLTp psuedoStruct (above)
		// property statisticsTrkpt mirrored in sqlSTp psuedoStruct (above)
		
	}
	
	func sqlCreateTpTable() -> Bool {
		if sqltpDbFileHandle != nil {
			do {
				let tpTable = Table(sqltpDbTableName)
				
				try sqltpDbFileHandle!.run(tpTable.create(ifNotExists: true) {t in
					t.column(sqltpDbTable.sqltpUniqueID, primaryKey: .autoincrement)
					t.column(sqltpDbTable.sqltpTrkID, unique: false)
					
					// mirror of FromValidEleTime  structure in Trkpt structure
					//	use acronym FVET to correspond to FromValidEleTime
					t.column(sqltpDbTable.sqlFVETlastValidIndex, unique: false)
					t.column(sqltpDbTable.sqlFVETdistance, unique: false)
					t.column(sqltpDbTable.sqlFVETgain, unique: false)
					t.column(sqltpDbTable.sqlFVETelapsedTime, unique: false)
					
					// mirror of FromValidDistTime  structure in Trkpt structure
					//	use acronym FVDT to correspond to FromValidDistTime
					t.column(sqltpDbTable.sqlFVDTlastValidIndex, unique: false)
					t.column(sqltpDbTable.sqlFVDTdistance, unique: false)
					t.column(sqltpDbTable.sqlFVDTelapsedTime, unique: false)
					
					// mirror of FromValidEleTrkPt  structure in Trkpt structure
					//	use acronym FVETp to correspond to FromValidEleTrkPt
					t.column(sqltpDbTable.sqlFVETplastValidIndex, unique: false)
					t.column(sqltpDbTable.sqlFVETpdistance, unique: false)
					t.column(sqltpDbTable.sqlFVETpgain, unique: false)
					t.column(sqltpDbTable.sqlFVETpelapsedTime, unique: false)
					
					// mirror of FromLastTrkPt  structure in Trkpt structure
					//	use acronym FLTp to correspond to FromLastTrkPt
					t.column(sqltpDbTable.sqlFLTplastValidIndex, unique: false)
					t.column(sqltpDbTable.sqlFLTpdistance, unique: false)
					t.column(sqltpDbTable.sqlFLTpgain, unique: false)
					
					// mirror of StatisticsTrkPt  structure in Trkpt structure
					//	use acronym STp to correspond to StatisticsTrkPt
					t.column(sqltpDbTable.sqlSTplastValidIndex, unique: false)
					t.column(sqltpDbTable.sqlSTpdistance, unique: false)
					t.column(sqltpDbTable.sqlSTpgain, unique: false)
					t.column(sqltpDbTable.sqlSTpelapsedTime, unique: false)
					
					// mirror properties of TrkPt
					//	use acronym Tp to correspond to TrkPt (help distinguish from Track properties
					t.column(sqltpDbTable.sqlIndex, unique: false)
					t.column(sqltpDbTable.sqlHasValidElevation, unique: false)
					t.column(sqltpDbTable.sqlHasValidTimeStamp, unique: false)
					t.column(sqltpDbTable.sqlLatitude, unique: false)
					t.column(sqltpDbTable.sqlLongitude, unique: false)
					t.column(sqltpDbTable.sqlElevation, unique: false)
					t.column(sqltpDbTable.sqlTimeStamp, unique: false)
								
				})
				return true
			} catch {
				Swift.print("catch - create tpTable failed \(error)")
				return false
			}
		}
		return false
	}
	
	func sqlInsertTrkptList( _ trackRowID: Int64, _ trkptList: [Trkpt]) -> Int {
		var trkptsAdded : Int = 0
		for trkptrow in 0 ... trkptList.count - 1 {
			let tpRowID = sqlInsertTpRow(Int(trackRowID), trkptList[trkptrow])
			if tpRowID >= 0 {
				trkptsAdded += 1
			}
		}
		return trkptsAdded
		
	}
	
	func sqlInsertTpRow( _ trackRowID: Int, _ trkpt: Trkpt) -> Int64 {								// insert a track into the sql database, return the row ID when the track was inserted.
			if sqltpDbFileHandle != nil {											// must have a valid file handle
				do {
								
					let tpTable = Table(sqltpDbTableName)
					let rowid = try sqltpDbFileHandle!.run(tpTable.insert(
						
						sqltpDbTable.sqltpTrkID <- trackRowID,
						
						sqltpDbTable.sqlFVETlastValidIndex <- trkpt.lastTimeEleTrkpt.lastValidIndex,
						sqltpDbTable.sqlFVETdistance <- trkpt.lastTimeEleTrkpt.distance,
						sqltpDbTable.sqlFVETgain <- trkpt.lastTimeEleTrkpt.gain,
						sqltpDbTable.sqlFVETelapsedTime <- trkpt.lastTimeEleTrkpt.elapsedTime,
						
						sqltpDbTable.sqlFVDTlastValidIndex <- trkpt.lastTimeDistTrkpt.lastValidIndex,
						sqltpDbTable.sqlFVDTdistance <- trkpt.lastTimeDistTrkpt.distance,
						sqltpDbTable.sqlFVDTelapsedTime <- trkpt.lastTimeDistTrkpt.elapsedTime,
						
						sqltpDbTable.sqlFVETplastValidIndex <- trkpt.lastEleTrkpt.lastValidIndex,
						sqltpDbTable.sqlFVETpdistance <- trkpt.lastEleTrkpt.distance,
						sqltpDbTable.sqlFVETpgain <- trkpt.lastEleTrkpt.gain,
						sqltpDbTable.sqlFVETpelapsedTime <- trkpt.lastEleTrkpt.elapsedTime,
						
						sqltpDbTable.sqlFLTplastValidIndex <- trkpt.lastTrkpt.lastValidIndex,
						sqltpDbTable.sqlFLTpdistance <- trkpt.lastTrkpt.distance,
						sqltpDbTable.sqlFLTpgain <- trkpt.lastTrkpt.gain,
						
						sqltpDbTable.sqlSTplastValidIndex <- trkpt.statisticsTrkpt.lastValidIndex,
						sqltpDbTable.sqlSTpdistance <- trkpt.statisticsTrkpt.distance,
						sqltpDbTable.sqlSTpgain <- trkpt.statisticsTrkpt.gain,
						sqltpDbTable.sqlSTpelapsedTime <- trkpt.statisticsTrkpt.elapsedTime,
						
						sqltpDbTable.sqlIndex <- trkpt.index,
						sqltpDbTable.sqlHasValidElevation <- trkpt.hasValidElevation,
						sqltpDbTable.sqlHasValidTimeStamp <- trkpt.hasValidTimeStamp,
						sqltpDbTable.sqlLatitude <- trkpt.latitude,
						sqltpDbTable.sqlLongitude <- trkpt.longitude,
						sqltpDbTable.sqlElevation <- trkpt.elevation,
						sqltpDbTable.sqlTimeStamp <- trkpt.timeStamp
																				
					))
					
					return rowid
				} catch {
					Swift.print("insertion failed: \(error)")
					return -1
				}
			} else {
				Swift.print("\(sqltpDbTableName) is empty")
				return -1
			}
		}
	
	func sqlRetrieveTrkptlist(_ trackRowID: Int) -> [Trkpt] {
		let rowIDexpression = Expression<Int>(String(trackRowID))
		let tpdbTable = Table(sqltpDbTableName)
		let query = tpdbTable.filter(sqltpDbTable.sqltpTrkID == rowIDexpression)
		var trkptsList = [Trkpt]()
				
		if let sqltpFileHandle = sqltpDbFileHandle {
			let results = try! sqltpFileHandle.prepare(query)
			var temptp = Trkpt()
			for key in results {
				
				temptp.lastTimeEleTrkpt.lastValidIndex = key[sqltpDbTable.sqlFVETlastValidIndex]
				temptp.lastTimeEleTrkpt.distance = key[sqltpDbTable.sqlFVETdistance]
				temptp.lastTimeEleTrkpt.gain = key[sqltpDbTable.sqlFVETgain]
				temptp.lastTimeEleTrkpt.elapsedTime = key[sqltpDbTable.sqlFVETelapsedTime]
				
				temptp.lastTimeDistTrkpt.lastValidIndex = key[sqltpDbTable.sqlFVDTlastValidIndex]
				temptp.lastTimeDistTrkpt.distance = key[sqltpDbTable.sqlFVDTdistance]
				temptp.lastTimeDistTrkpt.elapsedTime = key[sqltpDbTable.sqlFVDTelapsedTime]
				
				temptp.lastEleTrkpt.lastValidIndex = key[sqltpDbTable.sqlFVETplastValidIndex]
				temptp.lastEleTrkpt.distance = key[sqltpDbTable.sqlFVETpdistance]
				temptp.lastEleTrkpt.gain = key[sqltpDbTable.sqlFVETpgain]
				temptp.lastEleTrkpt.elapsedTime = key[sqltpDbTable.sqlFVETpelapsedTime]
				
				temptp.lastTrkpt.lastValidIndex = key[sqltpDbTable.sqlFLTplastValidIndex]
				temptp.lastTrkpt.distance = key[sqltpDbTable.sqlFLTpdistance]
				temptp.lastTrkpt.gain = key[sqltpDbTable.sqlFLTpgain]
				
				temptp.statisticsTrkpt.lastValidIndex = key[sqltpDbTable.sqlSTplastValidIndex]
				temptp.statisticsTrkpt.distance = key[sqltpDbTable.sqlSTpdistance]
				temptp.statisticsTrkpt.gain = key[sqltpDbTable.sqlSTpgain]
				temptp.statisticsTrkpt.elapsedTime = key[sqltpDbTable.sqlSTpelapsedTime]
				
				temptp.index = key[sqltpDbTable.sqlIndex]
				temptp.hasValidElevation = key[sqltpDbTable.sqlHasValidElevation]
				temptp.hasValidTimeStamp = key[sqltpDbTable.sqlHasValidTimeStamp]
				temptp.latitude = key[sqltpDbTable.sqlLatitude]
				temptp.longitude = key[sqltpDbTable.sqlLongitude]
				temptp.elevation = key[sqltpDbTable.sqlElevation]
				temptp.timeStamp = key[sqltpDbTable.sqlTimeStamp]
				trkptsList.append(temptp)
				temptp = .init()
				
			}
		}
		
		return trkptsList
	}
	
	func sqlGetAllRows() -> [Trkpt] {
		var trkptDb = [Trkpt]()
		var tempTP = Trkpt()
				
		let trkptDbTable = Table(sqltpDbTableName)
		var rowCount: Int = 0
		
		if let tpFileHandle = sqltpDbFileHandle {
			for key in try! tpFileHandle.prepare(trkptDbTable) {
				rowCount += 1
				//tempTP.trkIndex = key[sqltpDbTable.sqlTrkID]
				tempTP.index = key[sqltpDbTable.sqlIndex]
				tempTP.hasValidElevation = key[sqltpDbTable.sqlHasValidElevation]
				tempTP.hasValidTimeStamp = key[sqltpDbTable.sqlHasValidTimeStamp]
				tempTP.latitude = key[sqltpDbTable.sqlLatitude]
				tempTP.longitude = key[sqltpDbTable.sqlLongitude]
				tempTP.elevation = key[sqltpDbTable.sqlElevation]
				tempTP.timeStamp = key[sqltpDbTable.sqlTimeStamp]
				trkptDb.append(tempTP)
				
			}
		}
		return trkptDb
	}
}
