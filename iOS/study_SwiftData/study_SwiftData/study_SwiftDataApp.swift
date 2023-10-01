//
//  study_SwiftDataApp.swift
//  study_SwiftData
//
//  Created by Wing on 1/10/2023.
//

import SwiftData
import SwiftUI

@main
struct study_SwiftDataApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(DataManager().modelContainer)
    }
}
