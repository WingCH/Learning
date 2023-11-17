//
//  Your_first_presentationApp.swift
//  Your first presentation
//
//  Created by Wing on 22/10/2023.
//

import ComposableArchitecture
import SwiftData
import SwiftUI

@main
struct Your_first_presentationApp: App {
    var body: some Scene {
        WindowGroup {
            ContactsView(
                store: Store(
                    initialState: ContactsFeature.State(
                        contacts: [
                            Contact(id: UUID(), name: "Blob"),
                            Contact(id: UUID(), name: "Blob Jr"),
                            Contact(id: UUID(), name: "Blob Sr"),
                        ]
                    )
                ) {
                    ContactsFeature()
                }
            )
        }
    }
}
