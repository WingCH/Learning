//
//  WebViewController.swift
//  webview_inside_scrollview
//
//  Created by Wing on 7/5/2022.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    let webView = WKWebView()

    override func loadView() {
        super.loadView()
        view.addSubview(webView)
        webView.edgesToSuperview(usingSafeArea: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = URL(string: "https://wingch.site/content/iOS/WidgetsKit%20Transparent%20background.html") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
