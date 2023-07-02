//
//  TagView.swift
//  study_swiftui_flowlayout
//
//  Created by Wing on 2/7/2023.
//

import SwiftUI

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
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView(tag: TagModel(text: "Hello, World!", isSelected: true))
        TagView(tag: TagModel(text: "Hello, World!", isSelected: false))
    }
}
