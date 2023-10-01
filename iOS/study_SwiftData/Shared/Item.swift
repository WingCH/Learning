//
//  Item.swift
//  study_SwiftData
//
//  Created by Wing on 1/10/2023.
//

import Foundation
import SwiftData

@Model
final class Item {
    let timestamp: Date
    
    @Attribute(.externalStorage)
    let imageData: Data?
    
    init(timestamp: Date, imageData: Data?) {
        self.timestamp = timestamp
        self.imageData = imageData
    }
}
