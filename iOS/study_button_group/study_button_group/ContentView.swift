//
//  ContentView.swift
//  study_button_group
//
//  Created by Wing on 23/8/2023.
//

import SwiftUI

struct ContentView: View {
    @State var count: Int = 1
    var body: some View {
        VStack {
            ButtonGroup {
                ForEach(1 ..< count, id: \.self) { i in
                    CapsuleButton(imageName: "\(i).circle") {}
                }
            }
            .background(Color.red)
            .animation(.spring(), value: count)
            Button("Add") {
                count += 1
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
