//
//  DBViewControllerRepresentable.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 1/24/21.
//

import Cocoa
import SwiftUI




struct DBViewControllerRepresentable : NSViewControllerRepresentable {
	
	typealias NSViewType = DBViewController
	
	func makeNSViewController( context: NSViewControllerRepresentableContext<DBViewControllerRepresentable>) -> DBViewController {
		let mainStoryboard = NSStoryboard.init(name: "Main", bundle: nil)
		
		let dbViewController = mainStoryboard.instantiateController( withIdentifier: "dbViewControllerID") as! DBViewController
		//dbViewController.loadView()
		//dbViewController.dbTableview = NSTableView()
		//let x = dbViewController.dbTableview.reloadData()
		return dbViewController
	}
	
	
	func updateNSViewController(_ nsViewController: DBViewController, context: NSViewControllerRepresentableContext<DBViewControllerRepresentable>) {
		
	}
	
	
	
}
