//
//  ContentView.swift
//  study_share_extension
//
//  Created by Wing on 23/7/2023.
//

import SwiftUI

struct ContentView: View {
    @State var image: UIImage? = UserDefaults(suiteName: "group.com.wingch.study-share-extension")?.data(forKey: "sharedImage").flatMap(UIImage.init)

    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text("No image")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
