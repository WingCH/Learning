//
//  ViewController.swift
//  study_webview_image
//
//  Created by Wing on 7/3/2024.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView(frame: self.view.frame)
        webView.isInspectable = true
        self.view.addSubview(webView)

        loadHTMLStringIntoWebView()
    }

    func loadHTMLStringIntoWebView() {
        let bundleImagePath = Bundle.main.path(forResource: "imageFromBundle", ofType: "jpg") ?? ""
        print(bundleImagePath)
        let bundleImageURL = URL(fileURLWithPath: bundleImagePath)

        guard let base64Image = UIImage(named: "base64Image"), let imageData = base64Image.pngData() else {
            print("Image not found or cannot be converted")
            return
        }
        let base64String = imageData.base64EncodedString()

        guard let bundle2Path = Bundle.main.path(forResource: "Bundle2", ofType: "bundle"),
              let customBundle = Bundle(path: bundle2Path)
        else {
            print("Custom bundle not found.")
            return
        }

        guard let imageFromBundle2Path = customBundle.path(forResource: "imageFromBundle2", ofType: "jpg") else {
            print("Image not found in custom bundle.")
            return
        }

        let htmlString = """
        <html>
        <head>
        <style>
        body {
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        img {
            margin: 20px;
            width: 50%;  // Adjust the size as needed
            height: auto;
        }
        p {
          font-size: 2em;
        }
        </style>
        </head>
        <body>
        
        <p>Image from Main Bundle by path: "\(bundleImageURL.path)"</p>
        <img src="\(bundleImageURL.path)" alt="Image from Bundle">

        <p>Image from Main Bundle by name: "imageFromBundle.jpg"</p>
        <img src="imageFromBundle.jpg" alt="Image from Bundle">

        <p>Image from Bundle2 by path: "\(imageFromBundle2Path)"</p>
        <img src="\(imageFromBundle2Path)" alt="Image from Custom Bundle">

        <p>Base64 Embedded Image</p>
        <img src="data:image/png;base64,\(base64String)" alt="Base64 Embedded Image">
        </body>
        </html>
        """

        webView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
    }
}
