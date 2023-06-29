//
//  ContentView.swift
//  study_swiftui_draw_path
//
//  Created by Wing on 29/6/2023.
//  https://stackoverflow.com/a/67008132/5588637

import SwiftUI

struct ContentView: View {
    @State var paths: [PathContainer] = []
    @State var currentDraggingId = UUID()

    var body: some View {
        ZStack {
            // Background Color for the drawable area
            Color.blue
            ForEach(Array(paths.enumerated()), id: \.element.id) { index, container in
                // draw and set the foreground color of the paths to red
                container.path
                    .stroke(.red, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [5]))
                    .onTapGesture {
                        paths.remove(at: index)
                    }
            }
        }
        .gesture(drawGesture)
    }

    var drawGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                // The point that the gesture started from
                let start = value.startLocation
                // The point that the gesture ended to
                let end = value.location
                // the properties of the rectangle to be drawn
                let rectangle: CGRect = .init(origin: end,
                                              size: .init(width: start.x - end.x,
                                                          height: start.y - end.y))
                // create a path for the rectangle
                let path: Path = .init { path in
                    path.addRect(rectangle)
                }

                // remove the previous rectangle that was drawen in current
                // process of drawing
                paths.removeAll { $0.id == currentDraggingId }
                // append the new rectangle
                paths.append(.init(id: currentDraggingId, path: path))
            }
            .onEnded { _ in
                // renew the dragging id so the app know that the next
                // drag gesture is drawing a completely new rectangle,
                // and is not continuing the drawing of the last rectangle
                currentDraggingId = .init()
            }
    }
}

// An identifiable container for a path
struct PathContainer: Identifiable {
    let id: UUID
    let path: Path
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
