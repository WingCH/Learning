//
//  ContentView.swift
//  study_custom_gesture_in_swiftui
//
//  Created by Wing on 15/7/2023.
//  ref: https://sarunw.com/posts/move-view-around-with-drag-gesture-in-swiftui/

import SwiftUI

struct ContentView: View {
    @State private var location: CGPoint = CGPoint(x: 50, y: 50) // 1
    @GestureState private var fingerLocation: CGPoint? = nil
    @GestureState private var startLocation: CGPoint? = nil // 1

    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                var newLocation = startLocation ?? location // 3
                newLocation.x += value.translation.width
                newLocation.y += value.translation.height
                self.location = newLocation
            }.updating($startLocation) { _, startLocation, _ in
                startLocation = startLocation ?? location // 2
            }
    }

    var fingerDrag: some Gesture { // 2
        DragGesture()
            .updating($fingerLocation) { value, fingerLocation, _ in
                fingerLocation = value.location
            }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.pink)
                .frame(width: 100, height: 100)
                .position(location) // 2
                .gesture(
                    simpleDrag
                        .simultaneously(with: fingerDrag)
                )
            if let fingerLocation = fingerLocation { // 5
                Circle()
                    .stroke(Color.green, lineWidth: 2)
                    .frame(width: 44, height: 44)
                    .position(fingerLocation)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
