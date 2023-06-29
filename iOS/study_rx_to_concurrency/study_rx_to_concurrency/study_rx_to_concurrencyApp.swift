//
//  study_rx_to_concurrencyApp.swift
//  study_rx_to_concurrency
//
//  Created by Wing CHAN on 29/6/2023.
//

import SwiftUI

@main
struct study_rx_to_concurrencyApp: App {
    let rxProvider = RxProvider()
    let concurrencyProvider = ConcurrencyProvider(rxProvider: RxProvider())

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ContentViewModel(rxProvider: rxProvider, concurrencyProvider: concurrencyProvider))
        }
    }
}
