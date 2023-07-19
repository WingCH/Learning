//
//  TagView.swift
//  study_swiftui_flowlayout
//
//  Created by Wing on 2/7/2023.
//

import SwiftUI

struct TagAnchorModel: Equatable, Identifiable {
    let id: UUID
    let anchor: Anchor<CGRect>
}

struct TagAnchorPreferenceKey: PreferenceKey {
    static var defaultValue: [TagAnchorModel] = []
    static func reduce(
        value: inout [TagAnchorModel],
        nextValue: () -> [TagAnchorModel]
    ) {
        value.append(contentsOf: nextValue())
    }
}

struct TagModel: Identifiable {
    let id: UUID
    let text: String
    let isSelected: Bool

    init(id: UUID = UUID(), text: String, isSelected: Bool) {
        self.id = id
        self.text = text
        self.isSelected = isSelected
    }

    func copyWith(isSelected: Bool) -> TagModel {
        return TagModel(id: id, text: text, isSelected: isSelected)
    }
}

struct TagView: View {
    let tag: TagModel
    var body: some View {
        Text(tag.text)
            .padding()
            .background(.regularMaterial)
            .background(tag.isSelected ? .blue : .clear)
            .cornerRadius(15)
            .anchorPreference(key: TagAnchorPreferenceKey.self, value: .bounds) { anchor in
                [TagAnchorModel(id: tag.id, anchor: anchor)]
            }
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView(tag: TagModel(text: "Hello, World!", isSelected: true))
        TagView(tag: TagModel(text: "Hello, World!", isSelected: false))
    }
}
