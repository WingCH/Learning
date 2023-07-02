//
//  ContentView.swift
//  study_swiftui_theme
//
//  Created by Wing CHAN on 30/6/2023.
//

import SwiftUI

struct ContentView: View {
    @State var name: String = "Wing"

    var body: some View {
        VStack {
            RandomColorView()
            Text(name)
            Button {
                name = "M"
            } label: {
                Text("change name")
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
