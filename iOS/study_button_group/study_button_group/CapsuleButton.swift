//
//  CapsuleButton.swift
//  study_button_group
//
//  Created by Wing on 27/8/2023.
//

import SwiftUI

struct CapsuleButton: View {
    let imageName: String
    let action: () -> Void

    init(imageName: String, action: @escaping () -> Void) {
        self.imageName = imageName
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
                .font(.system(size: 32))
                .frame(width: 32, height: 32)
                .transition(.scale)
        }
        .padding()
        .background(.ultraThinMaterial, in: Capsule())
        .tint(.white)
    }
}

struct CapsuleButton_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }

    struct PreviewWrapper: View {
        @State private var position: CGPoint = CGPoint(x: 100, y: 100)
        var body: some View {
            VStack(alignment: .center) {
                CapsuleButton(imageName: "text.viewfinder") {}
                    .padding(16)
                    .background(Color.red)
                CapsuleButton(imageName: "text.magnifyingglass") {}
                    .padding(16)
                    .background(Color.red)
                CapsuleButton(imageName: "arrow.up.and.down.and.arrow.left.and.right") {}
                    .padding(16)
                    .background(Color.red)
                CapsuleButton(imageName: "doc.on.doc", action: {})
                    .padding(16)
                    .background(Color.red)
                // 做唔到同時兩個Gesture(drag & tap)
                // https://steipete.com/posts/supporting-both-tap-and-longpress-on-button-in-swiftui/
                CapsuleButton(imageName: "arrow.up.and.down.and.arrow.left.and.right", action: {})
                    .padding(16)
                    .background(Color.red)
                    .onDrag(position: $position)
                    .position(position)
            }
            .background(Color.gray)
        }
    }
}
