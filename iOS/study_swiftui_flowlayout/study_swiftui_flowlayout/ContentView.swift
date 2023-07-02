//
//  ContentView.swift
//  study_swiftui_flowlayout
//
//  Created by Wing on 2/7/2023.
//

import SwiftUI

struct ContentView: View {
    @State var tags: [TagModel] = []

    var body: some View {
        VStack(alignment: .leading) {
            FlowLayout(alignment: .leading) {
                ForEach(Array(tags.enumerated()), id: \.offset) { index, tag in
                    TagView(tag: tag)
                        .onTapGesture {
                            tags[index] = tag.copyWith(isSelected: !tag.isSelected)
                        }
                }
            }
            .background(Color.red)
            Text("Hello").background(Color.blue)
        }.onAppear {
            tags = [
                TagModel(text: "Hello", isSelected: true),
                TagModel(text: "World", isSelected: false),
                TagModel(text: "SwiftUI", isSelected: false),
                TagModel(text: "Swift", isSelected: false),
                TagModel(text: "SwiftUI", isSelected: false),
                TagModel(text: "Swift", isSelected: false),
                TagModel(text: "SwiftUI", isSelected: false),
                TagModel(text: "Swift", isSelected: false),
                TagModel(text: "SwiftUI", isSelected: false),
                TagModel(text: "Swift", isSelected: false),
                TagModel(text: "SwiftUI", isSelected: false),
                TagModel(text: "Swift", isSelected: false),
                TagModel(text: "SwiftUI", isSelected: false),
                TagModel(text: "Swift", isSelected: false),
                TagModel(text: "SwiftUI", isSelected: false),
                TagModel(text: "Swift", isSelected: false),
                TagModel(text: "SwiftUI", isSelected: false),
                TagModel(text: "Swift", isSelected: false),
            ]
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
