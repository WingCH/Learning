//
//  ContentView.swift
//  study_safeAreaInset
//
//  Created by Wing on 1/2/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<100) { index in
                        Text("Row \(index)")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.indigo)
                            .foregroundStyle(.white)
                    }
                }
                TextField("XXXXX", text: .constant(""))
            }
            .navigationTitle("Select a row")
            .safeAreaInset(edge: .bottom) {
                Text("Outside Safe Area")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.indigo)
            }
        }
    }
}

#Preview {
    ContentView()
}
