//
//  SwiftUIView.swift
//  ShareExtension
//
//  Created by Wing on 23/7/2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sharedData: SharedData
    var body: some View {
        switch(sharedData.imageStatue) {
        case .loading:
            Text("Loading...")
        case .success(let data):
            Image(uiImage: UIImage(data: data)!)
                .resizable()
                .aspectRatio(contentMode: .fit)
        case .failure(let error):
            Text(error.localizedDescription)
        
        }
    }
}
