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
    @State var lastInteractedTagId: UUID?
    @GestureState var fingerLocation: CGPoint? = nil

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear // make full screen size
            GeometryReader { geometryReader in
                FlowLayout(alignment: .leading) {
                    ForEach(Array(tags.enumerated()), id: \.offset) { index, tag in
                        TagView(tag: tag)
                            .onTapGesture {
                                let newTag = !tag.isSelected
                                tags[index] = tag
                            }
                    }
                }
                .onPreferenceChange(TagAnchorPreferenceKey.self) { value in
                    tagRects = value.map { geometryReader[$0.anchor] }
                    print("tagRects: \(tagRects)")
                }
                .background(Color.red)

                if let fingerLocation = fingerLocation {
                    Circle()
                        .stroke(Color.green, lineWidth: 2)
                        .frame(width: 44, height: 44)
                        .position(fingerLocation)
                }
            }
        }
        .gesture(
            // TODO: custom gesture
            // https://betterprogramming.pub/custom-gestures-in-swiftui-2-0-132590d66ee7
            DragGesture()
                .updating($fingerLocation) { value, fingerLocation, _ in
                    fingerLocation = value.location
                    print(fingerLocation)
                }
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
