//
//  ButtonGroup.swift
//  study_button_group
//
//  Created by Wing on 23/8/2023.
//

import SwiftUI

struct ButtonGroup: View {
    @State var offset: CGSize = .zero

    var body: some View {
        Grid {
            GridRow {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.blue)
                    .frame(width: 50, height: 50)

                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.blue)
                    .frame(width: 50, height: 50)
            }
            GridRow {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.blue)
                    .frame(width: 50, height: 50)

                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray)
                    .frame(width: 50, height: 50)
                    .gesture(
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
        }.offset(x: offset.width, y: offset.height)
    }
}

struct ButtonGroup_Previews: PreviewProvider {
    static var previews: some View {
        ButtonGroup()
    }
}
