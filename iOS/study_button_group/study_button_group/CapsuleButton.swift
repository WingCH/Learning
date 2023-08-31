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
        VStack {
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
        }
    }
}
