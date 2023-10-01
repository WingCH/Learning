//
//  Global.swift
//  study_SwiftData
//
//  Created by Wing on 1/10/2023.
//

import AppIntents
import Foundation
import SwiftData

final class DataManager {
    let modelContainer: ModelContainer

    init() {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
