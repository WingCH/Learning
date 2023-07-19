//
//  ContentView.swift
//  study_swiftui_to_image
//
//  Created by Wing on 18/7/2023.
//

import SwiftUI

// https://www.hackingwithswift.com/quick-start/swiftui/how-to-convert-a-swiftui-view-to-an-image
// 會出現不正常的形狀變化
extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        var images = [UIImage]()
        let snapshotHeight: CGFloat = UIScreen.main.bounds.height
        let targetSize = controller.view.intrinsicContentSize
        let totalHeight = targetSize.height
        view?.frame = CGRect(origin: .zero, size: targetSize)
        let iterations = ceil(totalHeight / snapshotHeight)

        for i in 0 ..< Int(iterations) {
            let yOffset = CGFloat(i) * snapshotHeight
            let partSize = CGSize(width: controller.view.intrinsicContentSize.width, height: min(snapshotHeight, totalHeight - yOffset))
            view?.frame = CGRect(origin: CGPoint(x: 0, y: -yOffset), size: controller.view.intrinsicContentSize)
            view?.backgroundColor = .clear

            let renderer = UIGraphicsImageRenderer(size: partSize)
            let image = renderer.image { _ in
                view?.drawHierarchy(in: CGRect(origin: CGPoint(x: 0, y: 0), size: partSize), afterScreenUpdates: true)
            }
            images.append(image)
        }

        return stitchImages(images: images, isVertical: true)
    }

    func stitchImages(images: [UIImage], isVertical: Bool) -> UIImage {
        var dimensions = CGSize.zero
        for image in images {
            if isVertical {
                dimensions.width = max(dimensions.width, image.size.width)
                dimensions.height += image.size.height
            } else {
                dimensions.width += image.size.width
                dimensions.height = max(dimensions.height, image.size.height)
            }
        }

        return UIGraphicsImageRenderer(size: dimensions).image { _ in
            var offset: CGFloat = 0
            for image in images {
                if isVertical {
                    image.draw(at: CGPoint(x: 0, y: offset))
                    offset += image.size.height
                } else {
                    image.draw(at: CGPoint(x: offset, y: 0))
                    offset += image.size.width
                }
            }
        }
    }
}

struct ContentView: View {
    var longVStack: some View {
        VStack {
            ForEach(0 ..< 46) { _ in
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
