//
//  ContentView.swift
//  study_swiftui_flowlayout
//
//  Created by Wing on 2/7/2023.
//

import SwiftUI

struct ContentView: View {
    @State var tags: [TagModel] = []
    @State var tagRects: [CGRect] = []
    @State var lastInteractedTagId: UUID?

    var body: some View {
        GeometryReader { geometryReader in
            FlowLayout(alignment: .leading) {
                ForEach(Array(tags.enumerated()), id: \.offset) { index, tag in
                    TagView(tag: tag)
                        .onTapGesture {
                            tags[index] = tag.copyWith(isSelected: !tag.isSelected)
                        }
                }
            }
            .onPreferenceChange(TagAnchorPreferenceKey.self) { value in
                tagRects = value.map { geometryReader[$0.anchor] }
            }.gesture(
                // TODO: custom gesture
                // https://betterprogramming.pub/custom-gestures-in-swiftui-2-0-132590d66ee7
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { dragValue in
                        // Check if drag location is within any tag rects
                        for (index, rect) in tagRects.enumerated() {
                            if rect.contains(dragValue.location) {
                                let tag = tags[index]
                                // Avoid repeating the action for the same tag during a single interaction
                                if lastInteractedTagId == tag.id {
                                    break
                                } else {
                                    tags[index] = tags[index].copyWith(isSelected: !tags[index].isSelected)
                                    lastInteractedTagId = tags[index].id
                                }
                                break
                            }
                        }
                    }
            )
            .background(Color.red)
            .onAppear {
                // Initial set of tags,
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

