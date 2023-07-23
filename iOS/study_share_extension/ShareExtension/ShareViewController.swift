//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Wing on 23/7/2023.
//

import MobileCoreServices
import Social
import UIKit
import UniformTypeIdentifiers

class ShareViewController: SLComposeServiceViewController {
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem
        let itemProvider = extensionItem?.attachments?.first as? NSItemProvider
        let typeIdentifier = UTType.image.identifier

        itemProvider?.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { [weak self] item, error in
            if let error = error {
                print("Error loading image: \(error)")
            } else if let url = item as? URL {
                // Handle URL: you might want to load the data from the URL
                do {
                    let imageData = try Data(contentsOf: url)
                    self?.saveImageToUserDefaults(imageData: imageData)
                } catch {
                    print("Error loading image data from URL: \(error)")
                }
            } else if let imageData = item as? Data {
                // Handle Data
                self?.saveImageToUserDefaults(imageData: imageData)
            }

            self?.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)

            let url = URL(string: "studyShareExtension://")!
            self?.openURL(url)
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

    private func saveImageToUserDefaults(imageData: Data) {
        let userDefaults = UserDefaults(suiteName: "group.com.wingch.study-share-extension") // replace with your app group id
        userDefaults?.set(imageData, forKey: "sharedImage")
        userDefaults?.synchronize()
    }

    // https://stackoverflow.com/questions/27506413/share-extension-to-open-containing-app/44499222#44499222
    // `Apple explicitly says extensions are not allowed to use UIApplication. It may work, but there's a high chance Apple will reject the app`
    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
}
