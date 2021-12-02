//
//  XMLFilesData.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 3/9/21.
//


import Combine
import SwiftUI

//final class	BPFiles: ObservableObject {

struct BPFiles {
	//@Published var xmlFiles : [ReturnStruct] = []
	var xmlFiles : [ReturnStruct] = []
	var xmlFilesAvailable : Bool {
		get {
			return !self.xmlFiles.isEmpty
		}
	}
}
