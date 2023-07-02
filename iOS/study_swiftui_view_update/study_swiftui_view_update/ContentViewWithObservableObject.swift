//
//  ContentViewWithObservableObject.swift
//  study_swiftui_theme
//
//  Created by Wing CHAN on 30/6/2023.
//

import SwiftUI

class ContentViewWithObservableObjectVM: ObservableObject {
    @Published var name: String = "Wing"

    func updateName() {
        name = "M"
    }
}

struct ContentViewWithObservableObject: View {
    @StateObject var vm: ContentViewWithObservableObjectVM

    var body: some View {
        VStack {
            RandomColorView()
            Text(vm.name)
            Button {
                vm.updateName()
            } label: {
                Text("change name")
            }
        }
        .padding()
    }
}

struct ContentViewWithObservableObject_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
