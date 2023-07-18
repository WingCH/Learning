//
//  ContentView.swift
//  study_swiftui_to_image
//
//  Created by Wing on 18/7/2023.
//

import SwiftUI

// https://www.hackingwithswift.com/quick-start/swiftui/how-to-convert-a-swiftui-view-to-an-image
extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.frame = CGRect(origin: CGPoint(x: 0, y: 0.0001), size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

struct ContentView: View {
    var longVStack: some View {
        VStack {
            ForEach(0 ..< 45) { _ in
                Text("Hello, world!")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1)))
            }
        }
    }

    var body: some View {
        VStack {
            ScrollView {
                longVStack
            }
            Button("Save to image") {
                let image = longVStack.edgesIgnoringSafeArea(.all).snapshot()
                // tested in iOS 15 16, 1-45 成功，但45以上就會白晒
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
