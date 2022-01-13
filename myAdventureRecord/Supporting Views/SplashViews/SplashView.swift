//
//  SplashView.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 10/25/21.
//

import SwiftUI
import SigmaSwiftStatistics
 
func calcDaysHoursMinutes(seconds: Double) -> (days: Int, hours: Int, minutes: Int) {
	let secondsperDay = secondsperHour * 24.0 // 86400
	let days = seconds/secondsperDay
	let hours = days.truncatingRemainder(dividingBy: 1.0)*24
	let minutes = hours.truncatingRemainder(dividingBy: 1.0)*60
	return(Int(days), Int(hours), Int(minutes))
	
}

func hikeMonthCount(dateArray: [String] ) -> [String: Int] {
		// dateArray format must be "MMM dd, yyyy"
	func getMonthString(dateString: String) -> String {
		return String(dateString.prefix(3))
	}
	func getMonthInt(dateString: String) -> Int {
		let df = DateFormatter()
		df.dateFormat = "MMM dd, yyyy"
		let hikeDate =  df.date(from: dateString)
		let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: hikeDate!)
		return components.month!
	}
	var hikeMonthDict : [String : Int] =   ["Jan" : 0, "Feb":0, "Mar":0,
											"Apr" : 0, "May":0, "Jun":0,
											"Jul" : 0, "Aug":0, "Sep":0,
											"Oct" : 0, "Nov":0, "Dec":0]
	
	for hike in dateArray {
		hikeMonthDict[getMonthString(dateString: hike)]! += 1
	}
	
	return hikeMonthDict
}

func leaderBoardBestMonth(dateArray: [String]) -> (month: String, count: Int) {
		// dateArray format must be "MMM dd, yyyy"
	
	let hikeMonthDict = hikeMonthCount(dateArray: dateArray)
	return (hikeMonthDict.first(where: { $1 == hikeMonthDict.values.max()!})!.key, hikeMonthDict.values.max()!)
}

struct SplashView: View {
	
	
	var filteredAdventures : [Adventure] = adventureData
	
    var body: some View {
		timeStampLog(message: "-> SplashView")
		
		return
		Group {
			if filteredAdventures.isEmpty {
				Text("No adventures")
			} else {
			VStack {
				GeometryReader { proxy in
					HStack {
						VStack {
						UpperStatsView(filteredAdventures: filteredAdventures)
						}
						.frame(width: proxy.size.width/2, height: proxy.size.height/2)
						VStack {
							MonthHistogramView(monthDict: hikeMonthCount(dateArray: filteredAdventures.compactMap({$0.hikeDate})))
							Text("Number of Hikes")
						}
						
					}
					
				}
					LowerStatsView(filteredAdventures: filteredAdventures)
						
				
			}//.frame( height: 500)
		}
		}
    }
}


struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
		SplashView()
    }
}
