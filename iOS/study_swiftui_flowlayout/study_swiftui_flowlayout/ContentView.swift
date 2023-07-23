//
//  ContentView.swift
//  study_swiftui_flowlayout
//
//  Created by Wing on 2/7/2023.
//

import SwiftUI

struct ContentView: View {
    @State var tags: [TagModel]
    @State var tagRects: [CGRect] = []
    @State var selectionRect: CGRect = .zero

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Expand the ZStack to fill the entire screen
            Color.clear

            // Flow layout with tags
            FlowLayout(alignment: .leading) {
                ForEach(Array(tags.enumerated()), id: \.offset) { index, tag in
                    // Tag view with tap gesture to toggle selection
                    TagView(tag: tag).onTapGesture {
                        tags[index] = tag.copyWith(isSelected: !tag.isSelected)
                    }
                }
            }
            .background(Color.red)

            // Calculate the rectangles for each tag
            .overlayPreferenceValue(TagAnchorPreferenceKey.self) { value in
                GeometryReader { geometryReader in
                    Color.clear.onAppear {
                        // Update the rectangles for each tag based on the anchor
                        tagRects = value.map { geometryReader[$0.anchor] }
                    }
                }
            }

            // View for visualizing the selection rectangle
            SelectionBoxView(selectionRect: selectionRect)
        }
        // Rectangle selection gesture for selecting tags
        .gesture(
            RectangleSelectionGesture(
                tags: $tags,
                selectionRect: $selectionRect,
                tagRects: tagRects
            )
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            tags: [
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
            ])
    }
}
