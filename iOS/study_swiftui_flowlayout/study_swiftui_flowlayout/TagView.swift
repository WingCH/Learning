//
//  TagView.swift
//  study_swiftui_flowlayout
//
//  Created by Wing on 2/7/2023.
//

import SwiftUI

struct TagView: View {
    let text: String
    var body: some View {
        Text(text)
            .padding()
            .background(.regularMaterial)
            .cornerRadius(15)
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView(text: "Hello, World!")
            .frame(width: 200, height: 200)
            .background(Color.red)
    }
}
