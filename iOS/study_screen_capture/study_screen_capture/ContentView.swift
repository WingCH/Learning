//
//  ContentView.swift
//  study_screen_capture
//
//  Created by Wing CHAN on 18/7/2023.
//

import SwiftUI

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .red

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            // not work now
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}


struct ContentView: View {
    var longVStack: some View {
        ForEach(0 ..< 100) { _ in
            Text("Hello, world!")
                .padding()
                .background(
                    Color(
                        red: Double.random(in: 0...1),
                        green: Double.random(in: 0...1),
                        blue: Double.random(in: 0...1)
                    )
                )
        }
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    longVStack
                }
            }
            Button("tap") {
                let image = longVStack.snapshot()
                // not work now 
                print(image)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
