//
//  ContentView.swift
//  study_old_swiftui_navigationView
//
//  Created by Wing CHAN on 3/7/2023.
//

import SwiftUI

struct SheetView: View {
    @Binding var showSheetView: Bool
    @State private var selection: String? = nil
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: Text("Third View"), tag: "Third", selection: $selection) { EmptyView() }
                Button("Tap to show third") {
                    self.selection = "Third"
                }
                Button("Dismiss") {
                    dismiss()
                }
            }
        }
    }
}

struct ChildView: View {
    var body: some View {
        Text("You cannot swipe back")
//            .navigationBarItems(leading: btnBack)
            // navigationBarBackButtonHidden will block swipe back gesture
            // search `UIGestureRecognizerDelegate` to fix this issue
//            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        print("fafafa")
                    } label: {
                        Text("Back")
                    }
                }
            }
    }
}

struct ContentView: View {
    @State var showSheetView = false
    @State private var selection: String? = nil
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: ChildView(),
                               tag: "Second", selection: $selection) { EmptyView() }

                Button("Tap to show second") {
                    self.selection = "Second"
                }

                Button("Show Full Screen Cover") {
                    self.showSheetView = true
                }
            }
            .navigationTitle("Navigation")
        }.fullScreenCover(
            isPresented: $showSheetView
        ) {
            SheetView(showSheetView: $showSheetView)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// navigationBarBackButtonHidden will block swipe back gesture
// use .navigationBarBackButtonHidden(true),  but keep swipe back gesture
// https://stackoverflow.com/a/60067845/5588637
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
