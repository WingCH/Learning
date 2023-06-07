//
//  Item.swift
//  study_xcode15
//
//  Created by Wing on 7/6/2023.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
