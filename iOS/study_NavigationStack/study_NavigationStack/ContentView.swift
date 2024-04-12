//
//  ContentView.swift
//  study_NavigationStack
//
//  Created by Wing on 31/3/2024.
//

import SwiftUI

struct ContentView: View {
    private var bgColors: [Color] = [.indigo, .yellow, .green, .orange, .brown]

    @State private var path: [Color] = []

    var body: some View {
        NavigationStack(path: $path) {
            List(bgColors, id: \.self) { bgColor in
                NavigationLink(value: bgColor) {
                    Text(bgColor.description)
                }
            }
            .listStyle(.plain)
            .navigationDestination(for: Color.self) { color in
                VStack {
                    Text("\(path.count), \(path.description)")
                        .font(.headline)
                    Button {
                        path = .init()
                    } label: {
                        Text("Back to Main")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    HStack {
                        ForEach(path, id: \.self) { color in
                            color
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    List(bgColors, id: \.self) { bgColor in
                        NavigationLink(value: bgColor) {
                            Text(bgColor.description)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Color")
        }
        .onAppear {
            
//            path.append(.indigo)
            path.append(.yellow)
            
        }
    }
}

#Preview {
    ContentView()
}
