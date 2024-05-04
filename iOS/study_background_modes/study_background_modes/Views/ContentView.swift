//
//  ContentView.swift
//  study_background_modes
//
//  Created by Wing on 4/5/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            AuthView()
                .tabItem {
                    VStack {
                        Image(systemName: "person.circle")
                        Text("Auth")
                    }
                }
            RefreshTaskView()
                .tabItem {
                    VStack {
                        Image(systemName: "arrow.clockwise.circle")
                        Text("Refresh Task")
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
