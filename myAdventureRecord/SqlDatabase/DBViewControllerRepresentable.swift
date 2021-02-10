//
//  DBViewControllerRepresentable.swift
//  myHikingRecord
//
//  Created by Robb Mankin on 1/24/21.
//

import Cocoa
import SwiftUI




struct DBViewControllerRepresentable : NSViewControllerRepresentable {
	// CRITICAL:  to make the representable work a storyboard entry with the identifier "dbViewControllerID" must be present
	//	in the Main storyboard of the application.  Further ALL IBOutlets declared in the dbControllerView must be connected
	//	via the storyboard
	
	class Coordinator: NSObject,  NSTabViewDelegate{
		
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator()
	}
	
	typealias NSViewType = DBViewController
	
	func makeNSViewController( context: NSViewControllerRepresentableContext<DBViewControllerRepresentable>) -> DBViewController {
		let mainStoryboard = NSStoryboard.init(name: "Main", bundle: nil)
		
		let dbViewController = mainStoryboard.instantiateController( withIdentifier: "dbViewControllerID") as! DBViewController
		//dbViewController.delegate = context.coordinator
		return dbViewController
	}
	
	
	func updateNSViewController(_ nsViewController: DBViewController, context: NSViewControllerRepresentableContext<DBViewControllerRepresentable>) {
		
	}
	
	
	
}
