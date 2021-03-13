//
//  XMLFilesData.swift
//  myAdventureRecord
//
//  Created by Robb Mankin on 3/9/21.
//


import Combine
import SwiftUI

final class	BPFiles: ObservableObject {
	@Published var xmlFiles : [ReturnStruct] = []
}
