//
//  Global.swift
//  study_SwiftData
//
//  Created by Wing on 1/10/2023.
//

import AppIntents
import Foundation
import SwiftData
import UIKit

@MainActor
final class DataManager {
    let modelContainer: ModelContainer

    static let shared = DataManager()

    var context: ModelContext {
        modelContainer.mainContext
    }

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

    func addItem(item: Item) async throws {
        context.insert(item)
        try modelContainer.mainContext.save()
    }

    func fetchItems() throws -> [Item] {
        var fetch: FetchDescriptor<Item> = {
//                   let predicate = #Predicate<Item> {
//
//                   }
//
//                   let sort = [SortDescriptor<Country>(\.population, order: .forward),
//                               SortDescriptor<Country>(\.name, order: .forward)]

            FetchDescriptor<Item>()
        }()
        return try context.fetch(fetch)
    }
}
