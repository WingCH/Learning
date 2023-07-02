//
//  ContentView.swift
//  study_swiftui_flowlayout
//
//  Created by Wing on 2/7/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading) {
            FlowLayout(alignment: .leading) {
                TagView(text: "Hello")
                TagView(text: "World")
                TagView(text: "!!!")
                TagView(text: "Hello")
                TagView(text: "World")
                TagView(text: "!!!")
            }
            .background(Color.red)
            Text("Hello").background(Color.blue)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
