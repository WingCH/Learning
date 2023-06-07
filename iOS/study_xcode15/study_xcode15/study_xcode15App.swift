//
//  study_xcode15App.swift
//  study_xcode15
//
//  Created by Wing on 7/6/2023.
//

import SwiftUI
import SwiftData

@main
struct study_xcode15App: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Item.self)
    }
}
