//
//  ContentView.swift
//  study_swiftui_fullScreenCover
//
//  Created by Wing CHAN on 20/7/2023.
//

import SwiftUI

struct CustomView: View {
    @Environment(\.customAlertDismiss) var customAlertDismiss: CustomAlertDismiss

    var body: some View {
        VStack {
            Button("Dismiss") {
                withAnimation {
                    customAlertDismiss.dismiss()
                }
            }
            .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5))
    }
}

struct ContentView: View {
    @State private var isPresented = false
    var body: some View {
        ZStack {
            VStack {
                Text("Test test")
                Button("Present!") {
                    withAnimation {
                        self.isPresented.toggle()
                    }
                }
            }
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .center
            )
            .background(Color.white)
            .customAlert(isPresented: $isPresented) {
                CustomView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
