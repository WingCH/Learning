//
//  ContentView.swift
//  pointfreeco_10112023
//
//  Created by Wing on 10/11/2023.
//  https://x.com/pointfreeco/status/1722733564838748441?s=20

import SwiftUI
import SwiftData

@Observable
class CounterModel {
    var count: Int
    init(count: Int = 0) {
        self.count = count
        // root cost
        // print("count: \(self.count)")
    }
}

struct ContentView: View {
    let model: CounterModel
    var body: some View {
        Form {
            Text(self.model.count.description)
            Button("Increment") {
                self.model.count += 1
            }
        }
    }

}

#Preview {
    ContentView(model: CounterModel())
}
