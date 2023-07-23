//
//  SharedData.swift
//  ShareExtension
//
//  Created by Wing on 23/7/2023.
//

import Foundation

class SharedData: ObservableObject {
    enum ImageStatue {
        case loading
        case success(data: Data)
        case failure(error: Error)
    }

    @Published var imageStatue: ImageStatue = .loading
}
