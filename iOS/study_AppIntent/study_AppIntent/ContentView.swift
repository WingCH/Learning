//
//  ContentView.swift
//  study_AppIntent
//
//  Created by Wing on 17/9/2023.
//

import SwiftUI

struct ContentView: View {
    let subjects = ["数学", "英語", "化学"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(0 ..< subjects.count, id: \.self) { index in
                    NavigationLink(destination: Image(subjects[index])) {
                        Text(subjects[index])
                    }
                }
            }.navigationBarTitle("科目一覧")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
