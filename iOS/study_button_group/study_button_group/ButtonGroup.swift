//
//  ButtonGroup.swift
//  study_button_group
//
//  Created by Wing on 23/8/2023.
//

import SwiftUI

struct ButtonGroup<Content: View>: View {
    @State var offset: CGSize = .zero
    let content: Content

    init(@ViewBuilder _ content: () -> Content) {
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
                    .highPriorityGesture(
                        // https://stackoverflow.com/a/69573041/5588637
                        DragGesture(coordinateSpace: .global).onChanged { value in
                            offset = value.translation
                        }
                        .onEnded { _ in
                            print("onEnded")
                            withAnimation(.spring()) {
                                offset = .zero
                            }
                        }
                    )
            }
        }
        .offset(x: offset.width, y: offset.height)
    }
}

struct ButtonGroup_Previews: PreviewProvider {
    static var previews: some View {
        ButtonGroup {
            CapsuleButton(imageName: "doc.on.doc", action: {})
            CapsuleButton(imageName: "text.viewfinder", action: {})
            CapsuleButton(imageName: "text.magnifyingglass", action: {})
        }
    }
}
