//
//  ButtonGroup.swift
//  study_button_group
//
//  Created by Wing on 23/8/2023.
//

import SwiftUI

struct ButtonGroup<Content: View>: View {
    @Binding private var position: CGPoint
    @GestureState private var fingerLocation: CGPoint? = nil
    @GestureState private var startLocation: CGPoint? = nil

    let content: Content

    init(position: Binding<CGPoint>, @ViewBuilder _ content: () -> Content) {
        self._position = position
        self.content = content()
    }

    var body: some View {
        Grid(alignment: .trailing) {
            GridRow {
                content
            }
            GridRow {
                CapsuleButton(imageName: "arrow.up.and.down.and.arrow.left.and.right", action: {})
                    .gridCellColumns(99)
                    .disabled(true)
                    .foregroundColor(Color.white)
                    .onDrag(position: $position)
            }
        }
        .position(position)
    }
}

struct ButtonGroup_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }

    // https://stackoverflow.com/a/59626213/5588637
    struct PreviewWrapper: View {
        @State private var position: CGPoint = CGPoint(x: 50, y: 50)

        var body: some View {
            ButtonGroup(position: $position) {
                CapsuleButton(imageName: "doc.on.doc", action: {})
                CapsuleButton(imageName: "text.viewfinder", action: {})
                CapsuleButton(imageName: "text.magnifyingglass", action: {})
            }
        }
    }
}
