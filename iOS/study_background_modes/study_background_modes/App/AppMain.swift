//
//  AppMain.swift
//  study_background_modes
//
//  Created by Wing on 4/5/2024.
//

import Foundation
import SwiftUI

@main
struct AppMain: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
