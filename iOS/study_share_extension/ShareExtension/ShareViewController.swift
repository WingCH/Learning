//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Wing on 23/7/2023.
//

import MobileCoreServices
import Social
import SwiftUI
import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    var sharedData = SharedData()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        let childView = UIHostingController(rootView: ContentView().environmentObject(sharedData))
        self.addChild(childView)
        childView.view.frame = self.view.bounds
        self.view.addSubview(childView.view)
        childView.didMove(toParent: self)

        let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem
        let itemProvider = extensionItem?.attachments?.first as? NSItemProvider
        let typeIdentifier = UTType.image.identifier

        itemProvider?.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { [weak self] item, error in
            guard let self = self else { return }
            if let error = error {
                updateImageStatue(imageStatue: .failure(error: error))
            } else if let url = item as? URL {
                do {
                    let imageData = try Data(contentsOf: url)
                    updateImageStatue(imageStatue: .success(data: imageData))
                } catch {
                    updateImageStatue(imageStatue: .failure(error: error))
                }
            } else if let imageData = item as? Data {
                updateImageStatue(imageStatue: .success(data: imageData))
            } else {
                updateImageStatue(imageStatue: .failure(error: NSError(domain: "Unknown Type", code: 0, userInfo: nil)))
            }
        }
    }

    func updateImageStatue(imageStatue: SharedData.ImageStatue) {
        DispatchQueue.main.async { [weak self] in
            self?.sharedData.imageStatue = imageStatue
        }
    }
}
