//
//  DetailView.swift
//  study_SwiftData
//
//  Created by Wing on 1/10/2023.
//

import SwiftUI

struct DetailView: View {
    let item: Item
    
    var body: some View {
        VStack {
            if let imageData = item.imageData,
                let image =  UIImage(data: imageData) {
                Image(uiImage: image)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
            } else {
                EmptyView()
            }
            
            Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
        }
    }
}

#Preview {
    DetailView(item: Item(timestamp: .now, imageData: nil))
}
