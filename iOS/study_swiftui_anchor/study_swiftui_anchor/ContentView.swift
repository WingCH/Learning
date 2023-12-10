//
//  ContentView.swift
//  study_swiftui_anchor
//
//  Created by Wing on 10/12/2023.
//

import SwiftUI

struct ContentView: View {
    @State var xOffset: CGFloat = 0

    var body: some View {
        VStack {
            AnchoredPosition(
                location: CGPoint(x: xOffset, y: 200),
                anchor: .center
            ) {
                ViewThatFits {
                    Text("Hello world").fixedSize()
                    Text("Hello").fixedSize()
                }.padding(2)
            }
            .frame(width: 300, height: 300).background(.blue)
            .overlay {
                Circle().frame(width: 3).position(CGPoint(x: xOffset, y: 200))
                    .foregroundColor(.red)
            }

            Slider(value: $xOffset, in: 0 ... 300)
        }
    }
}

#Preview {
    ContentView()
}
