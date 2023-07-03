//
//  ContentView.swift
//  study_old_swiftui_navigationView
//
//  Created by Wing CHAN on 3/7/2023.
//

import SwiftUI

struct SheetView: View {
    @Binding var showSheetView: Bool
    var body: some View {
        NavigationView {
            Text("List of notifications")
                .navigationBarTitle(Text("Notifications"), displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    print("Dismissing sheet view...")
                    self.showSheetView = false
                }) {
                    Text("Done").bold()
                })
        }
    }
}

struct ContentView: View {
    @State var showSheetView = false
    @State private var selection: String? = nil

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: Text("Second View"), tag: "Second", selection: $selection) { EmptyView() }
                NavigationLink(destination: Text("Third View"), tag: "Third", selection: $selection) { EmptyView() }
                Button("Tap to show second") {
                    self.selection = "Second"
                }
                Button("Tap to show third") {
                    self.selection = "Third"
                }
                Button("Show Full Screen Cover") {
                    self.showSheetView = true
                }
            }
            .navigationTitle("Navigation")
        }.fullScreenCover(
            isPresented: $showSheetView,
            onDismiss: {
                self.selection = "Second"
            }) {
                SheetView(showSheetView: $showSheetView)
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
