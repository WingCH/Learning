//
//  ContentView.swift
//  study_swiftui_flowlayout
//
//  Created by Wing on 2/7/2023.
//

import SwiftUI

struct ContentView: View {
    @State var tags: [TagModel] = []
    @State private var location: CGPoint = .zero

    var body: some View {
        ZStack {
            FlowLayout(alignment: .leading) {
                ForEach(Array(tags.enumerated()), id: \.offset) { index, tag in
                    TagView(tag: tag)
                        .onChange(of: location) { newLocation in
                            print("index: \(index), newLocation: \(newLocation)")
                        }
                        .onTapGesture {
                            tags[index] = tag.copyWith(isSelected: !tag.isSelected)
                        }
                }
            }.gesture(
                DragGesture(coordinateSpace: .local)
                    .onChanged {
                        location = $0.location
                    }
            )
            .background(Color.red)
            .onAppear {
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
