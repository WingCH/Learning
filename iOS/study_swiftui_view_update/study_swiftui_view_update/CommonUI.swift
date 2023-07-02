//
//  CommonUI.swift
//  study_swiftui_theme
//
//  Created by Wing CHAN on 30/6/2023.
//

import SwiftUI

struct RandomColorView: View {
    var body: some View {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
        .frame(width: 100, height: 100)
    }
}
