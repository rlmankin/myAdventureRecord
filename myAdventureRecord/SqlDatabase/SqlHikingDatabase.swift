//
//  HikingDatabase.swift
//  doHikingdbWin
//
//  Created by Robb Mankin on 3/8/18.
//  Copyright © 2018 Robb Mankin. All rights reserved.
//

import Cocoa
import SQLite

class SqlHikingDatabase: NSObject {
	
	var sqlDbURL : URL
	var sqlDbTable : TrkSqlTable
	var sqltpDbTable : TrkptsSqlTable
	var sqladvTable : AdventureSqlTable
	
	var sqlDbFileHandle : Connection?
	let sqlDbName : String = "/hikingdb.sqlite"
	let sqlDbTableName : String = "hikingdbTable"
	let sqltpDbTableName : String = "tpdbTable"
	let sqladvTableName : String = "advdbTable"
	
	let selectAllString = "SELECT uniqueID, header from "						// SQL query to get the uniqueID and the header from the database
	var tracks = [Track]()
	var trkpts = [Trkpt]()
	var adventures = [Adventure]()
	
	
	override init() {
		self.sqlDbURL = URL(string:sqlDbName)!									//  initialize to the sql database name
		self.sqlDbTable = TrkSqlTable()											//	create the database table
		self.sqltpDbTable = TrkptsSqlTable()									//	create the trkpts table
		self.sqladvTable = AdventureSqlTable()
		self.sqlDbFileHandle = nil												//	init the file handle to nil
		super.init()
		if self.sqlConnectOpenDb() {											//	connect and open the sql database
			tracks = self.sqlGetAllRows()										// 	populate 'tracks' with all the rows in the database (not sure how this works if the DB gets large)
			trkpts = self.sqlGetAllTpRows()
			adventures = self.sqlGetAllAdvRows()
		} else {
			print("error opening sqlDB in init")								//	for some reason we could not open and connect to the dB
		}
	}
	
	
	func sqlConnectOpenDb() -> Bool {
		let hikingDB = self
		let trkptsDb = self
		let dbFilePathString = hikingDB.getSqlDbFilePath()				// get the path to where the sql database is stored
		if dbFilePathString != nil {
			if let tempDbFileHandle = hikingDB.sqlDbConnect("\(dbFilePathString! + sqlDbName)") {	// try and form a connection to the sql database returns a Connction?
				//print("\(dbFilePathString! + sqlDbName) connected")
				sqlDbFileHandle = tempDbFileHandle
				let hikingDBSuccess =  hikingDB.sqlCreateDbTable()		// create the dbTable, returns Bool (true if table correctly created)
				let trkptsDbSuccess =  hikingDB.sqlCreateTpTable()			// create the trkpts Table, returns Bool (true if table correctly created)
				let advDbSuccess = hikingDB.sqlCreateAdvTable()			// create the adventure table, return Bool (true if table correctly created)
				
				return hikingDBSuccess && trkptsDbSuccess && advDbSuccess					// have to successfully open both tables
				
			} else {
				return false
			}
		} else {
			print("Error in database string creation")
			return false
		}
	}
	
	func getSqlDbFilePath() -> String? {										// Return a string with the path to the default dB found in Bundle.main.bundleIdentifier.
		let dbFileString = NSSearchPathForDirectoriesInDomains(					// find the appropriate location for the sql database (per Apple requriements).  The creation and open
			.documentDirectory, .userDomainMask, true					// of the database will NOT succeed if given an arbitrary path.  Not sure why, think it has something to do with sandbox.
			).first! +  "/hiking/hikingDatabase"
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

	
	struct TrkSqlTable {														// this sets the format and structure of the SQl database table.  It should mirror the structure Track
		///
		// doHikingDb calculated Stats
		///
		var sqlUniqueID = Expression<Int>("uniqueID")
		var sqlId = Expression<Int>("id")
		var sqlTrackURLString = Expression<String>("trackURLString")
		var sqlNumberOfDatapoints = Expression<Int>("numberOfDatapoints")
		var sqlHeader = Expression<String>("header")
		var sqlDistance = Expression<Double>("distance")
		var sqlStartElevation = Expression<Double>("startElevation")
		var sqlMaxElevation = Expression<Double>("maxElevation")
		var sqlMaxElevationIndex = Expression<Int>("maxElevationIndex")
		var sqlMinElevation = Expression<Double>("minElevation")
		var sqlMinElevationIndex = Expression<Int>("minElevationIndex")
		var sqlHikeDate = Expression<Date>("hikeDate")
		var sqlStartTime = Expression<Date>("startTime")
		var sqlEndTime = Expression<Date>("endTime")
		var sqlDuration = Expression<Double>("duration")
		var sqlTotalAscent = Expression<Double>("totalAscent")
		var sqlTotalAscentTime = Expression<Double>("totalAscentTime")
		var sqlTotalDescent = Expression<Double>("totalDescent")
		var sqlTotalDescentTime = Expression<Double>("totalDescentTime")
		var sqlNetAscent = Expression<Double>("netAscent")
		var sqlAvgDescentRate = Expression<Double>("avgDescentRate")
		var sqlAvgSpeed = Expression<Double>("avgSpeed")
		var sqlAvgAscentRate = Expression<Double>("avgAscentRate")
		
		var sqlGradeMaxEighth = Expression<Double>("gradeMaxEighth")
		var sqlGradeMaxEighthStartIndex = Expression<Int>("gradeMaxEighthStartIndex")
		var sqlGradeMaxEighthEndIndex = Expression<Int>("gradeMaxEighthEndIndex")
		
		var sqlGradeMaxMile = Expression<Double>("gradeMaxMile")
		var sqlGradeMaxMileStartIndex = Expression<Int>("gradeMaxMileStartIndex")
		var sqlGradeMaxMileEndIndex = Expression<Int>("gradeMaxMileEndIndex")
		
		var sqlGradeMinEighth = Expression<Double>("gradeMinEighth")
		var sqlGradeMinEighthStartIndex = Expression<Int>("gradeMinEighthStartIndex")
		var sqlGradeMinEighthEndIndex = Expression<Int>("gradeMinEighthEndIndex")
		
		
		var sqlGradeMinMile = Expression<Double>("gradeMinMile")
		var sqlGradeMinMileStartIndex = Expression<Int>("gradeMinMileStartIndex")
		var sqlGradeMinMileEndIndex = Expression<Int>("gradeMinMileEndIndex")
		
		var sqlSpeedMaxEighth = Expression<Double>("speedMaxEighth")
		var sqlSpeedMaxEighthStartIndex = Expression<Int>("speedMaxEighthStartIndex")
		var sqlSpeedMaxEighthEndIndex = Expression<Int>("speedMaxEighthEndIndex")
		
		var sqlSpeedMinEighth = Expression<Double>("speedMinEighth")
		var sqlSpeedMinEighthStartIndex = Expression<Int>("speedMinEighthStartIndex")
		var sqlSpeedMinEighthEndIndex = Expression<Int>("speedMinEighthEndIndex")
		
		var sqlSpeedMaxMile = Expression<Double>("speedMaxMile")
		var sqlSpeedMaxMileStartIndex = Expression<Int>("speedMaxMileStartIndex")
		var sqlSpeedMaxMileEndIndex = Expression<Int>("speedMaxMileEndIndex")
		
		var sqlSpeedMinMile = Expression<Double>("speedMinMile")
		var sqlSpeedMinMileStartIndex = Expression<Int>("speedMinMileStartIndex")
		var sqlSpeedMinMileEndIndex = Expression<Int>("speedMinMileEndIndex")
		
		var sqlAscentMaxEighth = Expression<Double>("ascentMaxEighth")
		var sqlAscentMaxEighthStartIndex = Expression<Int>("ascentMaxEighthStartIndex")
		var sqlAscentMaxEighthEndIndex = Expression<Int>("ascentMaxEighthEndIndex")
		
		var sqlAscentMinEighth = Expression<Double>("ascentMinEighth")
		var sqlAscentMinEighthStartIndex = Expression<Int>("ascentMinEighthStartIndex")
		var sqlAscentMinEighthEndIndex = Expression<Int>("ascentMinEighthEndIndex")
		
		var sqlAscentMaxMile = Expression<Double>("ascentMaxMile")
		var sqlAscentMaxMileStartIndex = Expression<Int>("ascentMaxMileStartIndex")
		var sqlAscentMaxMileEndIndex = Expression<Int>("ascentMaxMileEndIndex")
		
		var sqlAscentMinMile = Expression<Double>("ascentMinMile")
		var sqlAscentMinMileStartIndex = Expression<Int>("ascentMinMileStartIndex")
		var sqlAscentMinMileEndIndex = Expression<Int>("ascentMinMileEndIndex")
		
		var sqlAscentRateMaxEighth = Expression<Double>("ascentRateMaxEighth")
		var sqlAscentRateMaxEighthStartIndex = Expression<Int>("ascentRateMaxEighthStartIndex")
		var sqlAscentRateMaxEighthEndIndex = Expression<Int>("ascentRateMaxEighthEndIndex")
		
		var sqlAscentRateMinEighth = Expression<Double>("ascentRateMinEighth")
		var sqlAscentRateMinEighthStartIndex = Expression<Int>("ascentRateMinEighthStartIndex")
		var sqlAscentRateMinEighthEndIndex = Expression<Int>("ascentRateMinEighthEndIndex")
		
		var sqlAscentRateMaxMile = Expression<Double>("ascentRateMaxMile")
		var sqlAscentRateMaxMileStartIndex = Expression<Int>("ascentRateMaxMileStartIndex")
		var sqlAscentRateMaxMileEndIndex = Expression<Int>("ascentRateMaxMileEndIndex")
		
		var sqlAscentRateMinMile = Expression<Double>("ascentRateMinMile")
		var sqlAscentRateMinMileStartIndex = Expression<Int>("ascentRateMinMileStartIndex")
		var sqlAscentRateMinMileEndIndex = Expression<Int>("ascentRateMinMileEndIndex")
		
		var sqlAscentAvgRate = Expression<Double>("ascentAvgRate")
		var sqlAscentAvgRateStartIndex = Expression<Int>("ascentAvgRateStartIndex")
		var sqlAscentAvgRateEndIndex = Expression<Int>("ascentAvgRateEndIndex")
		
		var sqlDescentMaxEighth = Expression<Double>("descentMaxEIghth")
		var sqlDescentMaxEighthStartIndex = Expression<Int>("descentMaxEIghthStartIndex")
		var sqlDescentMaxEighthEndIndex = Expression<Int>("descentMaxEIghthEndIndex")
		
		var sqlDescentMinEighth = Expression<Double>("descentMinEighth")
		var sqlDescentMinEighthStartIndex = Expression<Int>("descentMinEIghthStartIndex")
		var sqlDescentMinEighthEndIndex = Expression<Int>("descentMinEIghthEndIndex")
		
		var sqlDescentMaxMile = Expression<Double>("descentMaxMile")
		var sqlDescentMaxMileStartIndex = Expression<Int>("descentMaxMileStartIndex")
		var sqlDescentMaxMileEndIndex = Expression<Int>("descentMaxMileEndIndex")
		
		var sqlDescentMinMile = Expression<Double>("descentMinMile")
		var sqlDescentMinMileStartIndex = Expression<Int>("descentMinMileStartIndex")
		var sqlDescentMinMileEndIndex = Expression<Int>("descentMinMileEndIndex")
		
		var sqlDescentRateMaxEighth = Expression<Double>("descentRateMaxEighth")
		var sqlDescentRateMaxEighthStartIndex = Expression<Int>("descentRateMaxEighthStartIndex")
		var sqlDescentRateMaxEighthEndIndex = Expression<Int>("descentRateMaxEighthEndIndex")
		
		var sqlDescentRateMinEighth = Expression<Double>("descentRateMinEighth")
		var sqlDescentRateMinEighthStartIndex = Expression<Int>("descentRateMinEighthStartIndex")
		var sqlDescentRateMinEighthEndIndex = Expression<Int>("descentRateMinEighthEndIndex")
		
		var sqlDescentRateMaxMile = Expression<Double>("descentRateMaxMile")
		var sqlDescentRateMaxMileStartIndex = Expression<Int>("descentRateMaxMileStartIndex")
		var sqlDescentRateMaxMileEndIndex = Expression<Int>("descentRateMaxMileEndIndex")
		
		var sqlDescentRateMinMile = Expression<Double>("descentRateMinMile")
		var sqlDescentRateMinMileStartIndex = Expression<Int>("descentRateMinMileStartIndex")
		var sqlDescentRateMinMileEndIndex = Expression<Int>("descentRateMinMileEndIndex")
		
		var sqlDescentAvgRate = Expression<Double>("descentAvgRate")
		var sqlDescentAvgRateStartIndex = Expression<Int>("descentAvgRateStartIndex")
		var sqlDescentAvgRateEndIndex = Expression<Int>("descentAvgRateEndIndex")
		
		///
		// Garmin calculated stats
		///
		
		var sqlGarminName = Expression<String?>("garminName")
		var sqlGarminTimerTime = Expression<String?>("garminTimerTime")
		var sqlGarminDistance = Expression<String?>("garminDistance")
		var sqlGarminTotalElapsedTime = Expression<String?>("garminTotalElapsedTime")
		var sqlGarminMovingTime = Expression<String?>("garminMovingTime")
		var sqlGarminStoppedTime = Expression<String?>("garminStoppedTime")
		var sqlGarminMovingSpeed = Expression<String?>("garminMovingSpeed")
		var sqlGarminMaxSpeed  = Expression<String?>("garminMaxSpeed")
		var sqlGarminMaxElevation  = Expression<String?>("garminMaxElevation")
		var sqlGarminMinElevation  = Expression<String?>("garminMinElevation")
		var sqlGarminAscent  = Expression<String?>("garminAscent")
		var sqlGarminDescent  = Expression<String?>("garminDescent")
		var sqlGarminAvgAscentRate  = Expression<String?>("garminAvgAscentRate")
		var sqlGarminMaxAscentRate  = Expression<String?>("garminMaxAscentRate")
		var sqlGarminAvgDescentRate  = Expression<String?>("garminAvgDescentRate")
		var sqlGarminMaxDescentRate  = Expression<String?>("garminMaxDescentRate")
		var sqlGarminCalories = Expression<String?>("garminCalories")
		var sqlTrackComment = Expression<String>("trackComment")
	}
	
	struct TrkptsSqlTable {			// track points database table, should mirror trkpt structure
									//	plus some overhead for links to corresponding track structure
		
		
		var sqltpUniqueID = Expression<Int>("tpuniqueID")
		
		// Link to track of which this track point is a member.  Use the sqlUniqueID
		var sqltpAssociatedTrackID = Expression<Int>("tpAssociatedTrackID")
		
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
	
	struct AdventureSqlTable {		// adventure table, should mirror adventure structure minus some duplications
									//	already captured in either the trackpoints table or the track table
		var sqladvTrkID = Expression<Int>("advuniqueID")
		var sqladvAssociatedTrackID = Expression<Int>("advAssociatedTrackID")
		var sqladvImageName = Expression<String>("advImageName")
		var sqladvDescription = Expression<String>("advDescription")
		var sqladvArea = Expression<String>("advArea")
		var sqladvIsFav = Expression<Bool>("advIsFav")
		var sqladvHikeCat = Expression<String>("advHikeCat")
	}
	
	func sqlCreateAdvTable() -> Bool {
		if sqlDbFileHandle != nil {
			do {
				let advTable = Table(sqladvTableName)
				try sqlDbFileHandle!.run(advTable.create(ifNotExists: true) { t in
					t.column(sqladvTable.sqladvTrkID, primaryKey: .autoincrement)
					t.column(sqladvTable.sqladvAssociatedTrackID, unique: false)
					t.column(sqladvTable.sqladvImageName)
					t.column(sqladvTable.sqladvDescription)
					t.column(sqladvTable.sqladvArea)
					t.column(sqladvTable.sqladvIsFav, unique: false)
					t.column(sqladvTable.sqladvHikeCat, unique: false)
				})
				return true
			} catch {
				Swift.print("catch - create advTable failed \(error)")
				return false
			}
			
		}
		return false
	}
	
	func sqlCreateTpTable() -> Bool {
		if sqlDbFileHandle != nil {
			do {
				let tpTable = Table(sqltpDbTableName)
				
				try sqlDbFileHandle!.run(tpTable.create(ifNotExists: true) {t in
					t.column(sqltpDbTable.sqltpUniqueID, primaryKey: .autoincrement)
					t.column(sqltpDbTable.sqltpAssociatedTrackID, unique: false)
					
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
	
	func sqlCreateDbTable() -> Bool {				// This creates the actual DbTable in the SQL database.  This must mirror the structure 'TrkSQLTable'
		if sqlDbFileHandle != nil {
			do {
				let dbTable = Table(sqlDbTableName)
				
				try sqlDbFileHandle!.run(dbTable.create(ifNotExists: true) {t in
					
					t.column(sqlDbTable.sqlUniqueID, primaryKey: .autoincrement)
						t.column(sqlDbTable.sqlId, unique:false)
						t.column(sqlDbTable.sqlTrackURLString, unique:false)
						t.column(sqlDbTable.sqlNumberOfDatapoints, unique: false)
						t.column(sqlDbTable.sqlHeader, unique:false)
						t.column(sqlDbTable.sqlDistance, unique:false)
						t.column(sqlDbTable.sqlStartElevation, unique:false)
						t.column(sqlDbTable.sqlMaxElevation, unique:false)
						t.column(sqlDbTable.sqlMaxElevationIndex, unique:false)
						t.column(sqlDbTable.sqlMinElevation, unique:false)
						t.column(sqlDbTable.sqlMinElevationIndex, unique:false)
						t.column(sqlDbTable.sqlHikeDate, unique:false)
						t.column(sqlDbTable.sqlStartTime, unique:false)
						t.column(sqlDbTable.sqlEndTime, unique:false)
						t.column(sqlDbTable.sqlDuration, unique:false)
						t.column(sqlDbTable.sqlTotalAscent, unique:false)
						t.column(sqlDbTable.sqlTotalAscentTime, unique:false)
						t.column(sqlDbTable.sqlTotalDescent, unique:false)
						t.column(sqlDbTable.sqlTotalDescentTime, unique:false)
						t.column(sqlDbTable.sqlNetAscent, unique:false)
						t.column(sqlDbTable.sqlAvgDescentRate, unique:false)
						t.column(sqlDbTable.sqlAvgSpeed, unique:false)
						t.column(sqlDbTable.sqlAvgAscentRate, unique:false)
						
						t.column(sqlDbTable.sqlGradeMaxEighth, unique:false)
						t.column(sqlDbTable.sqlGradeMaxEighthStartIndex, unique:false)
						t.column(sqlDbTable.sqlGradeMaxEighthEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlGradeMaxMile, unique:false)
						t.column(sqlDbTable.sqlGradeMaxMileStartIndex, unique:false)
						t.column(sqlDbTable.sqlGradeMaxMileEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlGradeMinEighth, unique:false)
						t.column(sqlDbTable.sqlGradeMinEighthStartIndex, unique:false)
						t.column(sqlDbTable.sqlGradeMinEighthEndIndex, unique:false)
						
						
						t.column(sqlDbTable.sqlGradeMinMile, unique:false)
						t.column(sqlDbTable.sqlGradeMinMileStartIndex, unique:false)
						t.column(sqlDbTable.sqlGradeMinMileEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlSpeedMaxEighth, unique:false)
						t.column(sqlDbTable.sqlSpeedMaxEighthStartIndex, unique:false)
						t.column(sqlDbTable.sqlSpeedMaxEighthEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlSpeedMinEighth, unique:false)
						t.column(sqlDbTable.sqlSpeedMinEighthStartIndex, unique:false)
						t.column(sqlDbTable.sqlSpeedMinEighthEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlSpeedMaxMile, unique:false)
						t.column(sqlDbTable.sqlSpeedMaxMileStartIndex, unique:false)
						t.column(sqlDbTable.sqlSpeedMaxMileEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlSpeedMinMile, unique:false)
						t.column(sqlDbTable.sqlSpeedMinMileStartIndex, unique:false)
						t.column(sqlDbTable.sqlSpeedMinMileEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlAscentMaxEighth, unique:false)
						t.column(sqlDbTable.sqlAscentMaxEighthStartIndex, unique:false)
						t.column(sqlDbTable.sqlAscentMaxEighthEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlAscentMinEighth, unique:false)
						t.column(sqlDbTable.sqlAscentMinEighthStartIndex, unique:false)
						t.column(sqlDbTable.sqlAscentMinEighthEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlAscentMaxMile, unique:false)
						t.column(sqlDbTable.sqlAscentMaxMileStartIndex, unique:false)
						t.column(sqlDbTable.sqlAscentMaxMileEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlAscentMinMile, unique:false)
						t.column(sqlDbTable.sqlAscentMinMileStartIndex, unique:false)
						t.column(sqlDbTable.sqlAscentMinMileEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlAscentRateMaxEighth, unique:false)
						t.column(sqlDbTable.sqlAscentRateMaxEighthStartIndex, unique:false)
						t.column(sqlDbTable.sqlAscentRateMaxEighthEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlAscentRateMinEighth, unique:false)
						t.column(sqlDbTable.sqlAscentRateMinEighthStartIndex, unique:false)
						t.column(sqlDbTable.sqlAscentRateMinEighthEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlAscentRateMaxMile, unique:false)
						t.column(sqlDbTable.sqlAscentRateMaxMileStartIndex, unique:false)
						t.column(sqlDbTable.sqlAscentRateMaxMileEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlAscentRateMinMile, unique:false)
						t.column(sqlDbTable.sqlAscentRateMinMileStartIndex, unique:false)
						t.column(sqlDbTable.sqlAscentRateMinMileEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlAscentAvgRate, unique:false)
						t.column(sqlDbTable.sqlAscentAvgRateStartIndex, unique:false)
						t.column(sqlDbTable.sqlAscentAvgRateEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlDescentMaxEighth, unique:false)
						t.column(sqlDbTable.sqlDescentMaxEighthStartIndex, unique:false)
						t.column(sqlDbTable.sqlDescentMaxEighthEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlDescentMinEighth, unique:false)
						t.column(sqlDbTable.sqlDescentMinEighthStartIndex, unique:false)
						t.column(sqlDbTable.sqlDescentMinEighthEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlDescentMaxMile, unique:false)
						t.column(sqlDbTable.sqlDescentMaxMileStartIndex, unique:false)
						t.column(sqlDbTable.sqlDescentMaxMileEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlDescentMinMile, unique:false)
						t.column(sqlDbTable.sqlDescentMinMileStartIndex, unique:false)
						t.column(sqlDbTable.sqlDescentMinMileEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlDescentRateMaxEighth, unique:false)
						t.column(sqlDbTable.sqlDescentRateMaxEighthStartIndex, unique:false)
						t.column(sqlDbTable.sqlDescentRateMaxEighthEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlDescentRateMinEighth, unique:false)
						t.column(sqlDbTable.sqlDescentRateMinEighthStartIndex, unique:false)
						t.column(sqlDbTable.sqlDescentRateMinEighthEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlDescentRateMaxMile, unique:false)
						t.column(sqlDbTable.sqlDescentRateMaxMileStartIndex, unique:false)
						t.column(sqlDbTable.sqlDescentRateMaxMileEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlDescentRateMinMile, unique:false)
						t.column(sqlDbTable.sqlDescentRateMinMileStartIndex, unique:false)
						t.column(sqlDbTable.sqlDescentRateMinMileEndIndex, unique:false)
						
						t.column(sqlDbTable.sqlDescentAvgRate, unique:false)
						t.column(sqlDbTable.sqlDescentAvgRateStartIndex, unique:false)
						t.column(sqlDbTable.sqlDescentAvgRateEndIndex, unique:false)
						
						///
						// Garmin calculated stats
						///
						
						t.column(sqlDbTable.sqlGarminName, unique:false)
						t.column(sqlDbTable.sqlGarminTimerTime, unique:false)
						t.column(sqlDbTable.sqlGarminDistance, unique:false)
						t.column(sqlDbTable.sqlGarminTotalElapsedTime, unique:false)
						t.column(sqlDbTable.sqlGarminMovingTime, unique:false)
						t.column(sqlDbTable.sqlGarminStoppedTime, unique:false)
						t.column(sqlDbTable.sqlGarminMovingSpeed, unique:false)
						t.column(sqlDbTable.sqlGarminMaxSpeed , unique:false)
						t.column(sqlDbTable.sqlGarminMaxElevation , unique:false)
						t.column(sqlDbTable.sqlGarminMinElevation , unique:false)
						t.column(sqlDbTable.sqlGarminAscent , unique:false)
						t.column(sqlDbTable.sqlGarminDescent , unique:false)
						t.column(sqlDbTable.sqlGarminAvgAscentRate , unique:false)
						t.column(sqlDbTable.sqlGarminMaxAscentRate , unique:false)
						t.column(sqlDbTable.sqlGarminAvgDescentRate , unique:false)
						t.column(sqlDbTable.sqlGarminMaxDescentRate , unique:false)
						t.column(sqlDbTable.sqlGarminCalories, unique:false)
						t.column(sqlDbTable.sqlTrackComment, unique:false)
					
					
					
					})			// } - closes 't in'  ) - closes 'try'
				//sqlDbFileHandle!.trace( {Swift.print( $0)})
				//Swift.print("table \(sqlDbTableName) created in createTable")
				return true
			} catch {
				Swift.print("catch - create Table Failed \(error)")
				return false
			}
		}
		return false
	}
	
	func sqlInsertDbRow( _ track: Track) -> Int64 {								// insert a track into the sql database, return the row ID when the track was inserted.
			if sqlDbFileHandle != nil {											// must have a valid file handle
				do {
					var startTime = Date()
					var hikeDate = Date()
					var endTime = Date()
					if let theTime = track.trackSummary.startTime {
						hikeDate = theTime
						startTime = theTime
					}
					if let theTime = track.trackSummary.endTime {
						endTime = theTime
					}
					
					let dbTable = Table(sqlDbTableName)
					let rowid = try sqlDbFileHandle!.run(dbTable.insert(			//  Insert the track into a row in the SQL database.  This must match the structure of the DbTable
						sqlDbTable.sqlId <- Int(track.trkUniqueID),
						sqlDbTable.sqlTrackURLString <-  track.trackURLString,
						sqlDbTable.sqlNumberOfDatapoints <- track.trackSummary.numberOfDatapoints,
						sqlDbTable.sqlHeader <-  track.header,
						sqlDbTable.sqlHikeDate <-  hikeDate,
						sqlDbTable.sqlStartTime <-  startTime,
						sqlDbTable.sqlEndTime <-  endTime,
						sqlDbTable.sqlDuration <-  track.trackSummary.duration,
						sqlDbTable.sqlDistance <-   track.trackSummary.distance,
						sqlDbTable.sqlStartElevation <-   track.trackSummary.startElevation,
						sqlDbTable.sqlMaxElevation <-   track.trackSummary.elevationStats.max.elevation,
						sqlDbTable.sqlMaxElevationIndex <- track.trackSummary.elevationStats.max.index,
						sqlDbTable.sqlMinElevation <-   track.trackSummary.elevationStats.min.elevation,
						sqlDbTable.sqlMinElevationIndex <- track.trackSummary.elevationStats.min.index,
						sqlDbTable.sqlTotalAscent <-   track.trackSummary.totalAscent,
						sqlDbTable.sqlTotalAscentTime <- track.trackSummary.totalAscentTime,
						sqlDbTable.sqlTotalDescent <-   track.trackSummary.totalDescent,
						sqlDbTable.sqlTotalDescentTime <- track.trackSummary.totalDescentTime,
						sqlDbTable.sqlNetAscent <-   track.trackSummary.netAscent,
						sqlDbTable.sqlAvgSpeed <-   track.trackSummary.avgSpeed,
						sqlDbTable.sqlAvgAscentRate <- track.trackSummary.avgAscentRate,
						sqlDbTable.sqlAvgDescentRate <- track.trackSummary.avgDescentRate,
						
						sqlDbTable.sqlGradeMaxEighth <-   track.trackSummary.eighthMileStats.grade.max.statData,
						sqlDbTable.sqlGradeMaxEighthStartIndex <-   track.trackSummary.eighthMileStats.grade.max.startIndex,
						sqlDbTable.sqlGradeMaxEighthEndIndex <-   track.trackSummary.eighthMileStats.grade.max.endIndex,
						
						sqlDbTable.sqlGradeMinEighth <-   track.trackSummary.eighthMileStats.grade.min.statData,
						sqlDbTable.sqlGradeMinEighthStartIndex <-   track.trackSummary.eighthMileStats.grade.min.startIndex,
						sqlDbTable.sqlGradeMinEighthEndIndex <-   track.trackSummary.eighthMileStats.grade.min.endIndex,
						
						sqlDbTable.sqlGradeMaxMile <-   track.trackSummary.mileStats.grade.max.statData,
						sqlDbTable.sqlGradeMaxMileStartIndex <-   track.trackSummary.mileStats.grade.max.startIndex,
						sqlDbTable.sqlGradeMaxMileEndIndex <-   track.trackSummary.mileStats.grade.max.endIndex,
						
						sqlDbTable.sqlGradeMinMile <-   track.trackSummary.mileStats.grade.min.statData,
						sqlDbTable.sqlGradeMinMileStartIndex <-   track.trackSummary.mileStats.grade.min.startIndex,
						sqlDbTable.sqlGradeMinMileEndIndex <-   track.trackSummary.mileStats.grade.min.endIndex,
						
						sqlDbTable.sqlSpeedMaxEighth <-   track.trackSummary.eighthMileStats.speed.max.statData,
						sqlDbTable.sqlSpeedMaxEighthStartIndex <-   track.trackSummary.eighthMileStats.speed.max.startIndex,
						sqlDbTable.sqlSpeedMaxEighthEndIndex <-   track.trackSummary.eighthMileStats.speed.max.endIndex,
						
						sqlDbTable.sqlSpeedMinEighth <-   track.trackSummary.eighthMileStats.speed.min.statData,
						sqlDbTable.sqlSpeedMinEighthStartIndex <-   track.trackSummary.eighthMileStats.speed.min.startIndex,
						sqlDbTable.sqlSpeedMinEighthEndIndex <-   track.trackSummary.eighthMileStats.speed.min.endIndex,
						
						sqlDbTable.sqlSpeedMaxMile <-   track.trackSummary.mileStats.speed.max.statData,
						sqlDbTable.sqlSpeedMaxMileStartIndex <-   track.trackSummary.mileStats.speed.max.startIndex,
						sqlDbTable.sqlSpeedMaxMileEndIndex <-   track.trackSummary.mileStats.speed.max.endIndex,
						
						sqlDbTable.sqlSpeedMinMile <-   track.trackSummary.mileStats.speed.min.statData,
						sqlDbTable.sqlSpeedMinMileStartIndex <-   track.trackSummary.mileStats.speed.min.startIndex,
						sqlDbTable.sqlSpeedMinMileEndIndex <-   track.trackSummary.mileStats.speed.min.endIndex,
						
						sqlDbTable.sqlAscentMaxEighth <-   track.trackSummary.eighthMileStats.ascent.max.statData,
						sqlDbTable.sqlAscentMaxEighthStartIndex <-   track.trackSummary.eighthMileStats.ascent.max.startIndex,
						sqlDbTable.sqlAscentMaxEighthEndIndex <-   track.trackSummary.eighthMileStats.ascent.max.endIndex,
						
						sqlDbTable.sqlAscentMinEighth <-   track.trackSummary.eighthMileStats.ascent.min.statData,
						sqlDbTable.sqlAscentMinEighthStartIndex <-   track.trackSummary.eighthMileStats.ascent.min.startIndex,
						sqlDbTable.sqlAscentMinEighthEndIndex <-   track.trackSummary.eighthMileStats.ascent.min.endIndex,
						
						sqlDbTable.sqlAscentMaxMile <-   track.trackSummary.mileStats.ascent.max.statData,
						sqlDbTable.sqlAscentMaxMileStartIndex <-   track.trackSummary.mileStats.ascent.max.startIndex,
						sqlDbTable.sqlAscentMaxMileEndIndex <-   track.trackSummary.mileStats.ascent.max.endIndex,
						
						sqlDbTable.sqlAscentMinMile <-   track.trackSummary.mileStats.ascent.min.statData,
						sqlDbTable.sqlAscentMinMileStartIndex <-   track.trackSummary.mileStats.ascent.min.startIndex,
						sqlDbTable.sqlAscentMinMileEndIndex <-   track.trackSummary.mileStats.ascent.min.endIndex,
						
						sqlDbTable.sqlAscentRateMaxEighth <-   track.trackSummary.eighthMileStats.ascentRate.max.statData,
						sqlDbTable.sqlAscentRateMaxEighthStartIndex <-   track.trackSummary.eighthMileStats.ascentRate.max.startIndex,
						sqlDbTable.sqlAscentRateMaxEighthEndIndex <-   track.trackSummary.eighthMileStats.ascentRate.max.endIndex,
						
						sqlDbTable.sqlAscentRateMinEighth <-   track.trackSummary.eighthMileStats.ascentRate.min.statData,
						sqlDbTable.sqlAscentRateMinEighthStartIndex <-   track.trackSummary.eighthMileStats.ascentRate.min.startIndex,
						sqlDbTable.sqlAscentRateMinEighthEndIndex <-   track.trackSummary.eighthMileStats.ascentRate.min.endIndex,
												
						sqlDbTable.sqlAscentRateMaxMile <-   track.trackSummary.mileStats.ascentRate.max.statData,
						sqlDbTable.sqlAscentRateMaxMileStartIndex <-   track.trackSummary.mileStats.ascentRate.max.startIndex,
						sqlDbTable.sqlAscentRateMaxMileEndIndex <-   track.trackSummary.mileStats.ascentRate.max.endIndex,
						
						sqlDbTable.sqlAscentRateMinMile <-   track.trackSummary.mileStats.ascentRate.min.statData,
						sqlDbTable.sqlAscentRateMinMileStartIndex <-   track.trackSummary.mileStats.ascentRate.min.startIndex,
						sqlDbTable.sqlAscentRateMinMileEndIndex <-   track.trackSummary.mileStats.ascentRate.min.endIndex,
						
						sqlDbTable.sqlAscentAvgRate <-   (track.trackSummary.avgAscentRate),
						sqlDbTable.sqlAscentAvgRateStartIndex <-   0,
						sqlDbTable.sqlAscentAvgRateEndIndex <-   0,
						
						sqlDbTable.sqlDescentMaxEighth <-   track.trackSummary.eighthMileStats.descent.max.statData,
						sqlDbTable.sqlDescentMaxEighthStartIndex <-   track.trackSummary.eighthMileStats.descent.max.startIndex,
						sqlDbTable.sqlDescentMaxEighthEndIndex <-   track.trackSummary.eighthMileStats.descent.max.endIndex,
						
						sqlDbTable.sqlDescentMinEighth <-   track.trackSummary.eighthMileStats.descent.min.statData,
						sqlDbTable.sqlDescentMinEighthStartIndex <-   track.trackSummary.eighthMileStats.descent.min.startIndex,
						sqlDbTable.sqlDescentMinEighthEndIndex <-   track.trackSummary.eighthMileStats.descent.min.endIndex,
						
						sqlDbTable.sqlDescentMaxMile <-   track.trackSummary.mileStats.descent.max.statData,
						sqlDbTable.sqlDescentMaxMileStartIndex <-   track.trackSummary.mileStats.descent.max.startIndex,
						sqlDbTable.sqlDescentMaxMileEndIndex <-   track.trackSummary.mileStats.descent.max.endIndex,
						
						sqlDbTable.sqlDescentMinMile <-   track.trackSummary.mileStats.descent.min.statData,
						sqlDbTable.sqlDescentMinMileStartIndex <-   track.trackSummary.mileStats.descent.min.startIndex,
						sqlDbTable.sqlDescentMinMileEndIndex <-   track.trackSummary.mileStats.descent.min.endIndex,
						
						sqlDbTable.sqlDescentRateMaxEighth <-   track.trackSummary.eighthMileStats.descentRate.max.statData,
						sqlDbTable.sqlDescentRateMaxEighthStartIndex <-   track.trackSummary.eighthMileStats.descentRate.max.startIndex,
						sqlDbTable.sqlDescentRateMaxEighthEndIndex <-   track.trackSummary.eighthMileStats.descentRate.max.endIndex,
						
						sqlDbTable.sqlDescentRateMinEighth <-   track.trackSummary.eighthMileStats.descentRate.min.statData,
						sqlDbTable.sqlDescentRateMinEighthStartIndex <-   track.trackSummary.eighthMileStats.descentRate.min.startIndex,
						sqlDbTable.sqlDescentRateMinEighthEndIndex <-   track.trackSummary.eighthMileStats.descentRate.min.endIndex,
						
						sqlDbTable.sqlDescentRateMaxMile <-   track.trackSummary.mileStats.descentRate.max.statData,
						sqlDbTable.sqlDescentRateMaxMileStartIndex <-   track.trackSummary.mileStats.descentRate.max.startIndex,
						sqlDbTable.sqlDescentRateMaxMileEndIndex <-   track.trackSummary.mileStats.descentRate.max.endIndex,
						
						sqlDbTable.sqlDescentRateMinMile <-   track.trackSummary.mileStats.descentRate.min.statData,
						sqlDbTable.sqlDescentRateMinMileStartIndex <-   track.trackSummary.mileStats.descentRate.min.startIndex,
						sqlDbTable.sqlDescentRateMinMileEndIndex <-   track.trackSummary.mileStats.descentRate.min.endIndex,
						
						sqlDbTable.sqlDescentAvgRate <-   (track.trackSummary.avgDescentRate),
						sqlDbTable.sqlDescentAvgRateStartIndex <-   0,
						sqlDbTable.sqlDescentAvgRateEndIndex <-   0,
						///
					// Garmin calculated stats
					///
						sqlDbTable.sqlGarminName <-  track.header,
						sqlDbTable.sqlGarminTimerTime <-   track.garminSummaryStats["TimerTime"],
						sqlDbTable.sqlGarminDistance <-   track.garminSummaryStats["Distance"],
						sqlDbTable.sqlGarminTotalElapsedTime <-   track.garminSummaryStats["TotalElapsedTime"],
						sqlDbTable.sqlGarminMovingTime <-   track.garminSummaryStats["MovingTime"],
						sqlDbTable.sqlGarminStoppedTime <-   track.garminSummaryStats["StoppedTime"],
						sqlDbTable.sqlGarminMovingSpeed <-   track.garminSummaryStats["MovingSpeed"],
						sqlDbTable.sqlGarminMaxSpeed  <-   track.garminSummaryStats["MaxSpeed"],
						sqlDbTable.sqlGarminMaxElevation  <-  track.garminSummaryStats["MaxElevation"],
						sqlDbTable.sqlGarminMinElevation  <-  track.garminSummaryStats["MinElevation"],
						sqlDbTable.sqlGarminAscent  <-   track.garminSummaryStats["Ascent"],
						sqlDbTable.sqlGarminDescent  <-   track.garminSummaryStats["Descent"],
						sqlDbTable.sqlGarminAvgAscentRate  <-   track.garminSummaryStats["AvgAscentRate"],
						sqlDbTable.sqlGarminMaxAscentRate  <-   track.garminSummaryStats["MaxAscentRate"],
						sqlDbTable.sqlGarminAvgDescentRate  <-   track.garminSummaryStats["AvgDescentRate"],
						sqlDbTable.sqlGarminMaxDescentRate  <-   track.garminSummaryStats["MaxDescentRate"],
						sqlDbTable.sqlGarminCalories <-   track.garminSummaryStats["Calories"],
															sqlDbTable.sqlTrackComment <- track.trackComment))										// initial insert has no comment
					//Swift.print("inserted id: \(rowid)")
					//sqlDbFileHandle!.trace( {Swift.print( $0)})
					return rowid
				} catch {
					Swift.print("insertion failed: \(error)")
					return -1
				}
			} else {
				Swift.print("\(sqlDbTableName) is empty")
				return -1
			}
		}
	
	func sqlInsertTpRow( _ trackRowID: Int, _ trkpt: Trkpt) -> Int64 {								// insert a track into the sql database, return the row ID when the track was inserted.
			if sqlDbFileHandle != nil {											// must have a valid file handle
				do {
								
					let tpTable = Table(sqltpDbTableName)
					let rowid = try sqlDbFileHandle!.run(tpTable.insert(
						
						sqltpDbTable.sqltpAssociatedTrackID <- trackRowID,
						
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
	
	func sqlInsertTrkptList( _ trackRowID: Int64, _ trkptList: [Trkpt]) -> Int {
		var trkptsAdded : Int = 0
		guard !trkptList.isEmpty else {
			print("trkptsList count is 0")
			return 0
		}
		for trkptrow in 0 ... trkptList.count - 1 {
			let tpRowID = sqlInsertTpRow(Int(trackRowID), trkptList[trkptrow])
			if tpRowID >= 0 {
				trkptsAdded += 1
			}
		}
		return trkptsAdded
		
	}
	
	func sqlUpdateAdvRow(_ trackRowID: Int, _ partial: inout Adventure) -> Int64 {
		if let advFileHandle = sqlDbFileHandle {
			let rowIDExpression = Expression<Int>(String(trackRowID))
			let advdbTable = Table(sqladvTableName)
			let query = advdbTable.filter(sqladvTable.sqladvTrkID == rowIDExpression)
			do {
				let rowid = try advFileHandle.run( query.update(
					// add name update
								sqladvTable.sqladvImageName <- partial.imageName,
								sqladvTable.sqladvDescription <- partial.description,
								sqladvTable.sqladvIsFav <- partial.isFavorite,
								sqladvTable.sqladvHikeCat <- partial.hikeCategory.description,
								sqladvTable.sqladvArea <- partial.area
								)
							)
				return Int64(rowid)
				
			} catch {
				print("update failed \(error)")
				return -2
			}
		} else {
			Swift.print("\(sqladvTable) is empty")
			return -3
		}
	}
	
	func sqlUpdateTrkRow(_ trackRowID: Int, _ adventure: Adventure) -> Int64 {
		if let trkFileHandle = sqlDbFileHandle {
			let rowIDExpression = Expression<Int>(String(trackRowID))
			let trkdbTable = Table(sqlDbTableName)
			let query = trkdbTable.filter(sqlDbTable.sqlUniqueID == rowIDExpression)
			do {
				let rowid = try trkFileHandle.run( query.update(
					sqlDbTable.sqlHeader <- adventure.trackData.header,
					sqlDbTable.sqlTrackComment <- adventure.trackData.trackComment
					)
				)
				return Int64(rowid)
				
			} catch {
				print("update failed \(error)")
				return -2
			}
		} else {
			Swift.print("\(sqladvTable) is empty")
			return -3
		}
	}
	
	func sqlInsertToAllTables( track : Track) -> Int64 {
			//	open and connect to the hinkingdbTable of the SQL hiking database
		let trackRow = self.sqlInsertDbRow(track)
		let trkptRow = self.sqlInsertTrkptList(trackRow, track.trkptsList)
		let tempAdv = loadAdventureTrack(track: track)
		let advRow = self.sqlInsertAdvRow(trackRow, tempAdv)
		return trackRow
	}
	
	
	func sqlInsertAdvRow( _ trackRowID: Int64, _ adventure: Adventure) -> Int64 {
		if sqlDbFileHandle != nil {
			do {
				let advTable = Table(sqladvTableName)
				let rowid = try sqlDbFileHandle!.run(advTable.insert(
					sqladvTable.sqladvAssociatedTrackID	 <- Int(trackRowID),
					sqladvTable.sqladvImageName <- adventure.imageName,
					sqladvTable.sqladvDescription <- adventure.description,
					sqladvTable.sqladvArea <- adventure.area,
					sqladvTable.sqladvIsFav <- adventure.isFavorite,
					sqladvTable.sqladvHikeCat <- adventure.hikeCategory.description
					
				))
				
				return rowid
			} catch {
				Swift.print("insertion faild: \(error)")
				return -1
			}
		} else {
			Swift.print("\(sqladvTable) is empty")
			return -1
		}
	}
	
	func sqlRetrieveAdventure(_ trackRowID: Int, _ partial: inout Adventure) {
		let rowIDExpression = Expression<Int>(String(trackRowID))
		let advdbTable = Table(sqladvTableName)
		let query = advdbTable.filter(sqladvTable.sqladvTrkID == rowIDExpression)
		//var adventure = Adventure()
		if let advFileHandle = sqlDbFileHandle {
			let results = try! advFileHandle.prepare(query)
			for key in results {
				partial.associatedTrackID = key[sqladvTable.sqladvAssociatedTrackID]
				partial.imageName = key[sqladvTable.sqladvImageName]
				partial.description = key[sqladvTable.sqladvDescription]
				partial.area = key[sqladvTable.sqladvArea]
				partial.isFavorite = key[sqladvTable.sqladvIsFav]
				switch key[sqladvTable.sqladvHikeCat] {
					case "Hike": partial.hikeCategory = Adventure.HikeCategory.hike
					case "Walkabout" : partial.hikeCategory = Adventure.HikeCategory.walkabout
					case "Off Road": partial.hikeCategory = Adventure.HikeCategory.orv
					case "Scenic Drive" : partial.hikeCategory = Adventure.HikeCategory.scenicDrive
					case "Snowshoe" : partial.hikeCategory = Adventure.HikeCategory.snowshoe
					case "Not Categorized" : partial.hikeCategory = Adventure.HikeCategory.none
					default : partial.hikeCategory = Adventure.HikeCategory.none
				}
			}
		}
	}

	func sqlRetrieveTrkptlist(_ trackRowID: Int) -> [Trkpt] {
		let rowIDexpression = Expression<Int>(String(trackRowID))
		let tpdbTable = Table(sqltpDbTableName)
		let query = tpdbTable.filter(sqltpDbTable.sqltpAssociatedTrackID == rowIDexpression)
		var trkptsList = [Trkpt]()
				
		if let tpFileHandle = sqlDbFileHandle {
			let results = try! tpFileHandle.prepare(query)
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
	
	
	func reloadTracks(someRows : [Int] = []) {									// Provide an array of row numbers (uniqueID)
		if someRows.isEmpty {
			self.tracks.removeAll()
			self.tracks = self.sqlGetAllRows()
			self.trkpts = self.sqlGetAllTpRows()
			self.adventures = self.sqlGetAllAdvRows()
		} else {
			self.tracks.removeAll()
			self.tracks = self.sqlGetSomeRows(someRows)
		}
	}
	
	func sqlGetSomeRows(_ someRows : [Int]) -> [Track]{
		var trackDb = [Track]()													// the collection of rows to be returned
		for rowID in someRows {
			let rowIDExpression = Expression<Int>(String(rowID))
			let dbTable = Table(sqlDbTableName)
			let query = dbTable.filter(sqlDbTable.sqlUniqueID == rowIDExpression)
			if let sqlFileHandle = sqlDbFileHandle {
				let results = try! sqlFileHandle.prepare(query)
				var tempTrack = Track()
				for key in results {
					tempTrack.trkUniqueID = key[sqlDbTable.sqlUniqueID]
					tempTrack.header = String(key[sqlDbTable.sqlHeader])
					tempTrack.trackSummary.startTime = key[sqlDbTable.sqlHikeDate]
					tempTrack.trackSummary.distance = Double(key[sqlDbTable.sqlDistance])
					tempTrack.trackSummary.duration = key[sqlDbTable.sqlDuration]
					tempTrack.trackSummary.elevationStats.max.elevation = key[sqlDbTable.sqlMaxElevation]
					tempTrack.trackSummary.totalAscent = key[sqlDbTable.sqlTotalAscent]
					tempTrack.trackSummary.totalDescent = key[sqlDbTable.sqlTotalDescent]
					tempTrack.trackSummary.avgSpeed = key[sqlDbTable.sqlAvgSpeed]
					trackDb.append(tempTrack)
				}
			}
		}
		return trackDb
	}
	
	
	
	func sqlGetAllRows() -> [Track] {											// This method will get all rows in the 'sqlHikingDatabase' and
																				//	place them in the collection 'trackDb'
		var trackDb = [Track]()													// the collection of rows to be returned
		var tempTrack = Track()													// a single track to place all column entries for a particular row
		let dateFmt = DateFormatter()
		dateFmt.dateFormat =  "MM/dd/yyyy"										// set the data format for the hikeDate
		let dbTable = Table(sqlDbTableName)								// get the sql database table.  'sqlDbTableName' is global to HikingDatabase class
		var rowCount: Int = 0
		if let sqlFileHandle = sqlDbFileHandle {
			for key in try! sqlFileHandle.prepare(dbTable) {
				rowCount += 1
				tempTrack.trkUniqueID = key[sqlDbTable.sqlUniqueID]
				tempTrack.header = String(key[sqlDbTable.sqlHeader])
				tempTrack.trackSummary.startTime = key[sqlDbTable.sqlHikeDate]
				tempTrack.trackSummary.distance = Double(key[sqlDbTable.sqlDistance])
				tempTrack.trackSummary.duration = key[sqlDbTable.sqlDuration]
				tempTrack.trackSummary.elevationStats.max.elevation = key[sqlDbTable.sqlMaxElevation]
				tempTrack.trackSummary.elevationStats.max.index = key[sqlDbTable.sqlMaxElevationIndex]
				tempTrack.trackSummary.elevationStats.min.elevation = key[sqlDbTable.sqlMinElevation]
				tempTrack.trackSummary.elevationStats.min.index = key[sqlDbTable.sqlMinElevationIndex]
				tempTrack.trackSummary.totalAscent = key[sqlDbTable.sqlTotalAscent]
				tempTrack.trackSummary.totalDescent = key[sqlDbTable.sqlTotalDescent]
				tempTrack.trackSummary.avgSpeed = key[sqlDbTable.sqlAvgSpeed]
				tempTrack.trackURLString = key[sqlDbTable.sqlTrackURLString]
				tempTrack.trackComment = key[sqlDbTable.sqlTrackComment]
				tempTrack.trackSummary.numberOfDatapoints = key[sqlDbTable.sqlNumberOfDatapoints]
				tempTrack.trackSummary.startElevation = key[sqlDbTable.sqlStartElevation]
				tempTrack.trackSummary.elevationStats.max.index = key[sqlDbTable.sqlMaxElevationIndex]
				tempTrack.trackSummary.elevationStats.min.index = key[sqlDbTable.sqlMinElevationIndex]
				tempTrack.trackSummary.endTime = key[sqlDbTable.sqlEndTime]
				tempTrack.trackSummary.totalAscentTime = key[sqlDbTable.sqlTotalAscentTime]
				tempTrack.trackSummary.totalDescentTime = key[sqlDbTable.sqlTotalDescentTime]
				tempTrack.trackSummary.netAscent = key[sqlDbTable.sqlNetAscent]
				tempTrack.trackSummary.avgAscentRate = key[sqlDbTable.sqlAvgAscentRate]
				tempTrack.trackSummary.avgSpeed = key[sqlDbTable.sqlAvgSpeed]
				tempTrack.trackSummary.avgDescentRate = key[sqlDbTable.sqlAvgDescentRate]
				
				tempTrack.trackSummary.eighthMileStats.grade.max.statData = key[sqlDbTable.sqlGradeMaxEighth]
				tempTrack.trackSummary.eighthMileStats.grade.max.startIndex = key[sqlDbTable.sqlGradeMaxEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.grade.max.endIndex = key[sqlDbTable.sqlGradeMaxEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.grade.min.statData = key[sqlDbTable.sqlGradeMinEighth]
				tempTrack.trackSummary.eighthMileStats.grade.min.startIndex = key[sqlDbTable.sqlGradeMinEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.grade.min.endIndex = key[sqlDbTable.sqlGradeMinEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.speed.max.statData = key[sqlDbTable.sqlSpeedMaxEighth]
				tempTrack.trackSummary.eighthMileStats.speed.max.startIndex = key[sqlDbTable.sqlSpeedMaxEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.speed.max.endIndex = key[sqlDbTable.sqlSpeedMaxEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.speed.min.statData = key[sqlDbTable.sqlSpeedMinEighth]
				tempTrack.trackSummary.eighthMileStats.speed.min.startIndex = key[sqlDbTable.sqlSpeedMinEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.speed.min.endIndex = key[sqlDbTable.sqlSpeedMinEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.ascent.max.statData = key[sqlDbTable.sqlAscentMaxEighth]
				tempTrack.trackSummary.eighthMileStats.ascent.max.startIndex = key[sqlDbTable.sqlAscentMaxEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.ascent.max.endIndex = key[sqlDbTable.sqlAscentMaxEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.ascent.min.statData = key[sqlDbTable.sqlAscentMinEighth]
				tempTrack.trackSummary.eighthMileStats.ascent.min.startIndex = key[sqlDbTable.sqlAscentMinEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.ascent.min.endIndex = key[sqlDbTable.sqlAscentMinEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.ascentRate.max.statData = key[sqlDbTable.sqlAscentRateMaxEighth]
				tempTrack.trackSummary.eighthMileStats.ascentRate.max.startIndex = key[sqlDbTable.sqlAscentRateMaxEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.ascentRate.max.endIndex = key[sqlDbTable.sqlAscentRateMaxEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.ascentRate.min.statData = key[sqlDbTable.sqlAscentRateMinEighth]
				tempTrack.trackSummary.eighthMileStats.ascentRate.min.startIndex = key[sqlDbTable.sqlAscentRateMinEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.ascentRate.min.endIndex = key[sqlDbTable.sqlAscentRateMinEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.descent.max.statData = key[sqlDbTable.sqlDescentMaxEighth]
				tempTrack.trackSummary.eighthMileStats.descent.max.startIndex = key[sqlDbTable.sqlDescentMaxEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.descent.max.endIndex = key[sqlDbTable.sqlDescentMaxEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.descent.min.statData = key[sqlDbTable.sqlDescentMinEighth]
				tempTrack.trackSummary.eighthMileStats.descent.min.startIndex = key[sqlDbTable.sqlDescentMinEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.descent.min.endIndex = key[sqlDbTable.sqlDescentMinEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.descentRate.max.statData = key[sqlDbTable.sqlDescentRateMaxEighth]
				tempTrack.trackSummary.eighthMileStats.descentRate.max.startIndex = key[sqlDbTable.sqlDescentRateMaxEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.descentRate.max.endIndex = key[sqlDbTable.sqlDescentRateMaxEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.descentRate.min.statData = key[sqlDbTable.sqlDescentRateMinEighth]
				tempTrack.trackSummary.eighthMileStats.descentRate.min.startIndex = key[sqlDbTable.sqlDescentRateMinEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.descentRate.min.endIndex = key[sqlDbTable.sqlDescentRateMinEighthEndIndex]
				
				
				
				
				
				
				
				tempTrack.trackSummary.mileStats.grade.max.statData = key[sqlDbTable.sqlGradeMaxMile]
				tempTrack.trackSummary.mileStats.grade.max.startIndex = key[sqlDbTable.sqlGradeMaxMileStartIndex]
				tempTrack.trackSummary.mileStats.grade.max.endIndex = key[sqlDbTable.sqlGradeMaxMileEndIndex]
				
				tempTrack.trackSummary.mileStats.grade.min.statData = key[sqlDbTable.sqlGradeMinMile]
				tempTrack.trackSummary.mileStats.grade.min.startIndex = key[sqlDbTable.sqlGradeMinMileStartIndex]
				tempTrack.trackSummary.mileStats.grade.min.endIndex = key[sqlDbTable.sqlGradeMinMileEndIndex]
				
				tempTrack.trackSummary.mileStats.speed.max.statData = key[sqlDbTable.sqlSpeedMaxMile]
				tempTrack.trackSummary.mileStats.speed.max.startIndex = key[sqlDbTable.sqlSpeedMaxMileStartIndex]
				tempTrack.trackSummary.mileStats.speed.max.endIndex = key[sqlDbTable.sqlSpeedMaxMileEndIndex]
				
				tempTrack.trackSummary.mileStats.speed.min.statData = key[sqlDbTable.sqlSpeedMinMile]
				tempTrack.trackSummary.mileStats.speed.min.startIndex = key[sqlDbTable.sqlSpeedMinMileStartIndex]
				tempTrack.trackSummary.mileStats.speed.min.endIndex = key[sqlDbTable.sqlSpeedMinMileEndIndex]
				
				tempTrack.trackSummary.mileStats.ascent.max.statData = key[sqlDbTable.sqlAscentMaxMile]
				tempTrack.trackSummary.mileStats.ascent.max.startIndex = key[sqlDbTable.sqlAscentMaxMileStartIndex]
				tempTrack.trackSummary.mileStats.ascent.max.endIndex = key[sqlDbTable.sqlAscentMaxMileEndIndex]
				
				tempTrack.trackSummary.mileStats.ascent.min.statData = key[sqlDbTable.sqlAscentMinMile]
				tempTrack.trackSummary.mileStats.ascent.min.startIndex = key[sqlDbTable.sqlAscentMinMileStartIndex]
				tempTrack.trackSummary.mileStats.ascent.min.endIndex = key[sqlDbTable.sqlAscentMinMileEndIndex]
				
				tempTrack.trackSummary.mileStats.ascentRate.max.statData = key[sqlDbTable.sqlAscentRateMaxMile]
				tempTrack.trackSummary.mileStats.ascentRate.max.startIndex = key[sqlDbTable.sqlAscentRateMaxMileStartIndex]
				tempTrack.trackSummary.mileStats.ascentRate.max.endIndex = key[sqlDbTable.sqlAscentRateMaxMileEndIndex]
				
				tempTrack.trackSummary.mileStats.ascentRate.min.statData = key[sqlDbTable.sqlAscentRateMinMile]
				tempTrack.trackSummary.mileStats.ascentRate.min.startIndex = key[sqlDbTable.sqlAscentRateMinMileStartIndex]
				tempTrack.trackSummary.mileStats.ascentRate.min.endIndex = key[sqlDbTable.sqlAscentRateMinMileEndIndex]
				
				tempTrack.trackSummary.mileStats.descent.max.statData = key[sqlDbTable.sqlDescentMaxMile]
				tempTrack.trackSummary.mileStats.descent.max.startIndex = key[sqlDbTable.sqlDescentMaxMileStartIndex]
				tempTrack.trackSummary.mileStats.descent.max.endIndex = key[sqlDbTable.sqlDescentMaxMileEndIndex]
				
				tempTrack.trackSummary.mileStats.descentRate.max.statData = key[sqlDbTable.sqlDescentRateMaxMile]
				tempTrack.trackSummary.mileStats.descentRate.max.startIndex = key[sqlDbTable.sqlDescentRateMaxMileStartIndex]
				tempTrack.trackSummary.mileStats.descentRate.max.endIndex = key[sqlDbTable.sqlDescentRateMaxMileEndIndex]
				
				tempTrack.trackSummary.mileStats.descentRate.min.statData = key[sqlDbTable.sqlDescentRateMinMile]
				tempTrack.trackSummary.mileStats.descentRate.min.startIndex = key[sqlDbTable.sqlDescentRateMinMileStartIndex]
				tempTrack.trackSummary.mileStats.descentRate.min.endIndex = key[sqlDbTable.sqlDescentRateMinMileEndIndex]
				
				
				///
				// Garmin calculated stats
				///
				//tempTrack.header = key[sqlDbTable.sqlGarminName] ?? nullString
				tempTrack.garminSummaryStats["TimerTime"] = key[sqlDbTable.sqlGarminTimerTime]
				tempTrack.garminSummaryStats["Distance"] = key[sqlDbTable.sqlGarminDistance]
				tempTrack.garminSummaryStats["TotalElapsedTime"] =  key[sqlDbTable.sqlGarminTotalElapsedTime]
				tempTrack.garminSummaryStats["MovingTime"] = key[sqlDbTable.sqlGarminMovingTime]
				tempTrack.garminSummaryStats["StoppedTime"] = key[sqlDbTable.sqlGarminStoppedTime]
				tempTrack.garminSummaryStats["MovingSpeed"] = key[sqlDbTable.sqlGarminMovingSpeed]
				tempTrack.garminSummaryStats["MaxSpeed"] = key[sqlDbTable.sqlGarminMaxSpeed ]
				tempTrack.garminSummaryStats["MaxElevation"] = key[sqlDbTable.sqlGarminMaxElevation]
				tempTrack.garminSummaryStats["MinElevation"] = key[sqlDbTable.sqlGarminMinElevation]
				tempTrack.garminSummaryStats["Ascent"] = key[sqlDbTable.sqlGarminAscent]
				tempTrack.garminSummaryStats["Descent"] = key[sqlDbTable.sqlGarminDescent]
				tempTrack.garminSummaryStats["AvgAscentRate"] = key[sqlDbTable.sqlGarminAvgAscentRate]
				tempTrack.garminSummaryStats["MaxAscentRate"] = key[sqlDbTable.sqlGarminMaxAscentRate]
				tempTrack.garminSummaryStats["AvgDescentRate"] = key[sqlDbTable.sqlGarminAvgDescentRate]
				tempTrack.garminSummaryStats["MaxDescentRate"] = key[sqlDbTable.sqlGarminMaxDescentRate]
				tempTrack.garminSummaryStats["Calories"] = key[sqlDbTable.sqlGarminCalories]
				
				trackDb.append(tempTrack)
				
			}
		}
		return trackDb
	}
	
	func sqlGetAllTpRows() -> [Trkpt] {
		var trkptDb = [Trkpt]()
		var tempTP = Trkpt()
				
		let trkptDbTable = Table(sqltpDbTableName)
		var rowCount: Int = 0
		
		if let tpFileHandle = sqlDbFileHandle {
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
	
	func sqlGetAllAdvRows() -> [Adventure] {
		var advDb = [Adventure]()
		var tempAdventure = Adventure()
		let advDbTable = Table(sqladvTableName)
		var rowCount: Int = 0
		
		if let advFileHandle = sqlDbFileHandle {
			for key in try! advFileHandle.prepare(advDbTable) {
				rowCount += 1
				tempAdventure.description = key[sqladvTable.sqladvDescription]
				tempAdventure.area = key[sqladvTable.sqladvArea]
				tempAdventure.imageName = key[sqladvTable.sqladvImageName]
				tempAdventure.isFavorite = key[sqladvTable.sqladvIsFav]
				switch key[sqladvTable.sqladvHikeCat] {
					case "Hike": tempAdventure.hikeCategory = Adventure.HikeCategory.hike
					case "Walkabout" :tempAdventure.hikeCategory = Adventure.HikeCategory.walkabout
					case "Off Road": tempAdventure.hikeCategory = Adventure.HikeCategory.orv
					case "Scenic Drive" : tempAdventure.hikeCategory = Adventure.HikeCategory.scenicDrive
					case "Snowshoe" : tempAdventure.hikeCategory = Adventure.HikeCategory.snowshoe
					case "Not Categorized" : tempAdventure.hikeCategory = Adventure.HikeCategory.none
					default : tempAdventure.hikeCategory = Adventure.HikeCategory.none
				}
				advDb.append(tempAdventure)
			}
		}
		return advDb
			
	}
	
	//		Commenting is still required.  Very touchy/fragile routine.  Any mistake in handling the creation of the structure from the SQL retrieve
	//			will garble the resulting track
	func sqlRetrieveRecord(_ rowID: Int) -> Track?{
		let rowIDExpression = Expression<Int>(String(rowID))
		let dbTable = Table(sqlDbTableName)
		let query = dbTable.filter(sqlDbTable.sqlUniqueID == rowIDExpression)
		if let sqlFileHandle = sqlDbFileHandle {
			let results = try! sqlFileHandle.prepare(query)
			var tempTrack = Track()
			for key in results {
				tempTrack.trackURLString = key[sqlDbTable.sqlTrackURLString]
				tempTrack.trackComment = key[sqlDbTable.sqlTrackComment]
				tempTrack.trackSummary.numberOfDatapoints = key[sqlDbTable.sqlNumberOfDatapoints]
				tempTrack.trkUniqueID = Int(key[sqlDbTable.sqlId])
				tempTrack.header = key[sqlDbTable.sqlHeader]
				tempTrack.trackSummary.distance = key[sqlDbTable.sqlDistance]
				tempTrack.trackSummary.startElevation = key[sqlDbTable.sqlStartElevation]
				tempTrack.trackSummary.elevationStats.max.elevation = key[sqlDbTable.sqlMaxElevation]
				tempTrack.trackSummary.elevationStats.max.index = key[sqlDbTable.sqlMaxElevationIndex]
				tempTrack.trackSummary.elevationStats.min.elevation = key[sqlDbTable.sqlMinElevation]
				tempTrack.trackSummary.elevationStats.min.index = key[sqlDbTable.sqlMinElevationIndex]
				tempTrack.trackSummary.startTime = key[sqlDbTable.sqlStartTime]
				tempTrack.trackSummary.endTime = key[sqlDbTable.sqlEndTime]
				tempTrack.trackSummary.duration = key[sqlDbTable.sqlDuration]
				tempTrack.trackSummary.totalAscent = key[sqlDbTable.sqlTotalAscent]
				tempTrack.header = key[sqlDbTable.sqlHeader]
				tempTrack.trackSummary.duration = key[sqlDbTable.sqlDuration]
				tempTrack.trackSummary.distance = key[sqlDbTable.sqlDistance]
				tempTrack.trackSummary.totalAscent = key[sqlDbTable.sqlTotalAscent]
				tempTrack.trackSummary.totalAscentTime = key[sqlDbTable.sqlTotalAscentTime]
				tempTrack.trackSummary.totalDescent = key[sqlDbTable.sqlTotalDescent]
				tempTrack.trackSummary.totalDescentTime = key[sqlDbTable.sqlTotalDescentTime]
				tempTrack.trackSummary.netAscent = key[sqlDbTable.sqlNetAscent]
				tempTrack.trackSummary.avgAscentRate = key[sqlDbTable.sqlAvgAscentRate]
				tempTrack.trackSummary.avgSpeed = key[sqlDbTable.sqlAvgSpeed]
				tempTrack.trackSummary.avgDescentRate = key[sqlDbTable.sqlAvgDescentRate]
				
				
				tempTrack.trackSummary.eighthMileStats.grade.max.statData = key[sqlDbTable.sqlGradeMaxEighth]
				tempTrack.trackSummary.eighthMileStats.grade.max.startIndex = key[sqlDbTable.sqlGradeMaxEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.grade.max.endIndex = key[sqlDbTable.sqlGradeMaxEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.grade.min.statData = key[sqlDbTable.sqlGradeMinEighth]
				tempTrack.trackSummary.eighthMileStats.grade.min.startIndex = key[sqlDbTable.sqlGradeMinEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.grade.min.endIndex = key[sqlDbTable.sqlGradeMinEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.speed.max.statData = key[sqlDbTable.sqlSpeedMaxEighth]
				tempTrack.trackSummary.eighthMileStats.speed.max.startIndex = key[sqlDbTable.sqlSpeedMaxEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.speed.max.endIndex = key[sqlDbTable.sqlSpeedMaxEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.speed.min.statData = key[sqlDbTable.sqlSpeedMinEighth]
				tempTrack.trackSummary.eighthMileStats.speed.min.startIndex = key[sqlDbTable.sqlSpeedMinEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.speed.min.endIndex = key[sqlDbTable.sqlSpeedMinEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.ascent.max.statData = key[sqlDbTable.sqlAscentMaxEighth]
				tempTrack.trackSummary.eighthMileStats.ascent.max.startIndex = key[sqlDbTable.sqlAscentMaxEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.ascent.max.endIndex = key[sqlDbTable.sqlAscentMaxEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.ascent.min.statData = key[sqlDbTable.sqlAscentMinEighth]
				tempTrack.trackSummary.eighthMileStats.ascent.min.startIndex = key[sqlDbTable.sqlAscentMinEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.ascent.min.endIndex = key[sqlDbTable.sqlAscentMinEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.ascentRate.max.statData = key[sqlDbTable.sqlAscentRateMaxEighth]
				tempTrack.trackSummary.eighthMileStats.ascentRate.max.startIndex = key[sqlDbTable.sqlAscentRateMaxEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.ascentRate.max.endIndex = key[sqlDbTable.sqlAscentRateMaxEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.ascentRate.min.statData = key[sqlDbTable.sqlAscentRateMinEighth]
				tempTrack.trackSummary.eighthMileStats.ascentRate.min.startIndex = key[sqlDbTable.sqlAscentRateMinEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.ascentRate.min.endIndex = key[sqlDbTable.sqlAscentRateMinEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.descent.max.statData = key[sqlDbTable.sqlDescentMaxEighth]
				tempTrack.trackSummary.eighthMileStats.descent.max.startIndex = key[sqlDbTable.sqlDescentMaxEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.descent.max.endIndex = key[sqlDbTable.sqlDescentMaxEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.descent.min.statData = key[sqlDbTable.sqlDescentMinEighth]
				tempTrack.trackSummary.eighthMileStats.descent.min.startIndex = key[sqlDbTable.sqlDescentMinEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.descent.min.endIndex = key[sqlDbTable.sqlDescentMinEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.descentRate.max.statData = key[sqlDbTable.sqlDescentRateMaxEighth]
				tempTrack.trackSummary.eighthMileStats.descentRate.max.startIndex = key[sqlDbTable.sqlDescentRateMaxEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.descentRate.max.endIndex = key[sqlDbTable.sqlDescentRateMaxEighthEndIndex]
				
				tempTrack.trackSummary.eighthMileStats.descentRate.min.statData = key[sqlDbTable.sqlDescentRateMinEighth]
				tempTrack.trackSummary.eighthMileStats.descentRate.min.startIndex = key[sqlDbTable.sqlDescentRateMinEighthStartIndex]
				tempTrack.trackSummary.eighthMileStats.descentRate.min.endIndex = key[sqlDbTable.sqlDescentRateMinEighthEndIndex]
				
				tempTrack.trackSummary.mileStats.grade.max.statData = key[sqlDbTable.sqlGradeMaxMile]
				tempTrack.trackSummary.mileStats.grade.max.startIndex = key[sqlDbTable.sqlGradeMaxMileStartIndex]
				tempTrack.trackSummary.mileStats.grade.max.endIndex = key[sqlDbTable.sqlGradeMaxMileEndIndex]
				
				tempTrack.trackSummary.mileStats.grade.min.statData = key[sqlDbTable.sqlGradeMinMile]
				tempTrack.trackSummary.mileStats.grade.min.startIndex = key[sqlDbTable.sqlGradeMinMileStartIndex]
				tempTrack.trackSummary.mileStats.grade.min.endIndex = key[sqlDbTable.sqlGradeMinMileEndIndex]
				
				tempTrack.trackSummary.mileStats.speed.max.statData = key[sqlDbTable.sqlSpeedMaxMile]
				tempTrack.trackSummary.mileStats.speed.max.startIndex = key[sqlDbTable.sqlSpeedMaxMileStartIndex]
				tempTrack.trackSummary.mileStats.speed.max.endIndex = key[sqlDbTable.sqlSpeedMaxMileEndIndex]
				
				tempTrack.trackSummary.mileStats.speed.min.statData = key[sqlDbTable.sqlSpeedMinMile]
				tempTrack.trackSummary.mileStats.speed.min.startIndex = key[sqlDbTable.sqlSpeedMinMileStartIndex]
				tempTrack.trackSummary.mileStats.speed.min.endIndex = key[sqlDbTable.sqlSpeedMinMileEndIndex]
				
				tempTrack.trackSummary.mileStats.ascent.max.statData = key[sqlDbTable.sqlAscentMaxMile]
				tempTrack.trackSummary.mileStats.ascent.max.startIndex = key[sqlDbTable.sqlAscentMaxMileStartIndex]
				tempTrack.trackSummary.mileStats.ascent.max.endIndex = key[sqlDbTable.sqlAscentMaxMileEndIndex]
				
				tempTrack.trackSummary.mileStats.ascent.min.statData = key[sqlDbTable.sqlAscentMinMile]
				tempTrack.trackSummary.mileStats.ascent.min.startIndex = key[sqlDbTable.sqlAscentMinMileStartIndex]
				tempTrack.trackSummary.mileStats.ascent.min.endIndex = key[sqlDbTable.sqlAscentMinMileEndIndex]
				
				tempTrack.trackSummary.mileStats.ascentRate.max.statData = key[sqlDbTable.sqlAscentRateMaxMile]
				tempTrack.trackSummary.mileStats.ascentRate.max.startIndex = key[sqlDbTable.sqlAscentRateMaxMileStartIndex]
				tempTrack.trackSummary.mileStats.ascentRate.max.endIndex = key[sqlDbTable.sqlAscentRateMaxMileEndIndex]
				
				tempTrack.trackSummary.mileStats.ascentRate.min.statData = key[sqlDbTable.sqlAscentRateMinMile]
				tempTrack.trackSummary.mileStats.ascentRate.min.startIndex = key[sqlDbTable.sqlAscentRateMinMileStartIndex]
				tempTrack.trackSummary.mileStats.ascentRate.min.endIndex = key[sqlDbTable.sqlAscentRateMinMileEndIndex]
				
				tempTrack.trackSummary.mileStats.descent.max.statData = key[sqlDbTable.sqlDescentMaxMile]
				tempTrack.trackSummary.mileStats.descent.max.startIndex = key[sqlDbTable.sqlDescentMaxMileStartIndex]
				tempTrack.trackSummary.mileStats.descent.max.endIndex = key[sqlDbTable.sqlDescentMaxMileEndIndex]
				
				tempTrack.trackSummary.mileStats.descentRate.max.statData = key[sqlDbTable.sqlDescentRateMaxMile]
				tempTrack.trackSummary.mileStats.descentRate.max.startIndex = key[sqlDbTable.sqlDescentRateMaxMileStartIndex]
				tempTrack.trackSummary.mileStats.descentRate.max.endIndex = key[sqlDbTable.sqlDescentRateMaxMileEndIndex]
				
				tempTrack.trackSummary.mileStats.descentRate.min.statData = key[sqlDbTable.sqlDescentRateMinMile]
				tempTrack.trackSummary.mileStats.descentRate.min.startIndex = key[sqlDbTable.sqlDescentRateMinMileStartIndex]
				tempTrack.trackSummary.mileStats.descentRate.min.endIndex = key[sqlDbTable.sqlDescentRateMinMileEndIndex]
				
				
				///
				// Garmin calculated stats
				///
				tempTrack.header = key[sqlDbTable.sqlGarminName] ?? nullString
				tempTrack.garminSummaryStats["TimerTime"] = key[sqlDbTable.sqlGarminTimerTime]
				tempTrack.garminSummaryStats["Distance"] = key[sqlDbTable.sqlGarminDistance]
				tempTrack.garminSummaryStats["TotalElapsedTime"] =  key[sqlDbTable.sqlGarminTotalElapsedTime]
				tempTrack.garminSummaryStats["MovingTime"] = key[sqlDbTable.sqlGarminMovingTime]
				tempTrack.garminSummaryStats["StoppedTime"] = key[sqlDbTable.sqlGarminStoppedTime]
				tempTrack.garminSummaryStats["MovingSpeed"] = key[sqlDbTable.sqlGarminMovingSpeed]
				tempTrack.garminSummaryStats["MaxSpeed"] = key[sqlDbTable.sqlGarminMaxSpeed ]
				tempTrack.garminSummaryStats["MaxElevation"] = key[sqlDbTable.sqlGarminMaxElevation]
				tempTrack.garminSummaryStats["MinElevation"] = key[sqlDbTable.sqlGarminMinElevation]
				tempTrack.garminSummaryStats["Ascent"] = key[sqlDbTable.sqlGarminAscent]
				tempTrack.garminSummaryStats["Descent"] = key[sqlDbTable.sqlGarminDescent]
				tempTrack.garminSummaryStats["AvgAscentRate"] = key[sqlDbTable.sqlGarminAvgAscentRate]
				tempTrack.garminSummaryStats["MaxAscentRate"] = key[sqlDbTable.sqlGarminMaxAscentRate]
				tempTrack.garminSummaryStats["AvgDescentRate"] = key[sqlDbTable.sqlGarminAvgDescentRate]
				tempTrack.garminSummaryStats["MaxDescentRate"] = key[sqlDbTable.sqlGarminMaxDescentRate]
				tempTrack.garminSummaryStats["Calories"] = key[sqlDbTable.sqlGarminCalories]
				//tempTrack.
				//print ("items: \(results)")
			} // for key
		return tempTrack
		//print("break here")
		} else {
			return nil
		}
	} // sqlRetrieveRecord
	
	func sqlDeleteRecord(_ rowID : Int) -> Bool {
		
		let rowIDExpression = Expression<Int>(String(rowID))
		let dbTable = Table(sqlDbTableName)
		let targetDelete = dbTable.filter(sqlDbTable.sqlUniqueID == rowIDExpression)
		do {
			if try sqlDbFileHandle!.run(targetDelete.delete()) > 0 {
				//print("row \(rowID) deleted")
				return true
			} else {
				print("row \(rowID) not found")
				return false
			}
		} catch {
			print("delete failed")
			return false
		}
	}
	
	func sqlQueryDb(_ sqlQuery: String) -> [Int]{								//  Takes an arbitrary SQLite query and returns an array containin the uniqueIDs of the
																				//		tracks that match the query
																
		var returnResults : [Int] = []											//  Initialize the return array
		let newSqlQuery = "SELECT uniqueID from hikingdbTable where " + sqlQuery//	Modify the query to format into a correctly formed Select statement
		if sqlDbFileHandle != nil {												//  Must have a valid FileHandle
			do {
				let results = try sqlDbFileHandle!.prepare(newSqlQuery)			//	Perform the Query, the query results are only the uniqueIDs of the tracks that match
				for row in results {											//	Iterate through the results formatting the results into a valid array of Int.
					returnResults.append(Int(Optional(row[0]) as! Int64))
				}
			
			} catch {
				print("query error")
			}
		}
		return returnResults
	}
	
	
	
}  //HikingDataBase
