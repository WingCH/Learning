//
//  study_tcaApp.swift
//  study_tca
//
//  Created by Wing on 22/6/2023.
//

import ComposableArchitecture
import SwiftUI

@main
struct study_tcaApp: App {
    static let store = Store(initialState: CounterFeature.State()) {
        CounterFeature()
            ._printChanges()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                store: study_tcaApp.store
            )
        }
    }
}
