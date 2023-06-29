//
//  Page2.swift
//  study-navigation-controller
//
//  Created by Wing CHAN on 29/6/2023.
//

import SwiftUI

struct SwiftUIPage: View {
    var onTapButton: (() -> Void)?
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            Button("back") {
                onTapButton?()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.purple)
    }
}

struct Page2_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIPage()
    }
}
