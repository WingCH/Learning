//
//  SharedData.swift
//  ShareExtension
//
//  Created by Wing on 23/7/2023.
//

import Foundation
import UIKit

class SharedData: ObservableObject {
    enum ImageStatue {
        case loading
        case success(uiImage: UIImage)
        case failure(error: Error)
    }

    @Published var imageStatue: ImageStatue = .loading
}
