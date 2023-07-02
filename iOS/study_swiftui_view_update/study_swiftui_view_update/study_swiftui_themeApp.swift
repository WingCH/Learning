//
//  study_swiftui_themeApp.swift
//  study_swiftui_theme
//
//  Created by Wing CHAN on 30/6/2023.
//

import SwiftUI

@main
struct study_swiftui_themeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentViewWithObservableObject(vm: .init())
        }
    }
}
