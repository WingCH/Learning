//
//  ViewController.swift
//  study_webview_observe_height
//
//  Created by Wing on 8/5/2024.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadWebPage()
    }

    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController.add(self, name: "notifyHeightChange")

        webView = WKWebView(frame: self.view.bounds, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.isInspectable = true
        view.addSubview(webView)
    }

    private func loadWebPage() {
        if let url = URL(string: "https://example.com") {
            webView.load(URLRequest(url: url))
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let js = """
        var resizeObserver = new ResizeObserver(entries => {
            for (let entry of entries) {
                var newHeight = document.body.offsetHeight;
                window.webkit.messageHandlers.notifyHeightChange.postMessage(newHeight);
            }
        });
        resizeObserver.observe(document.body);
        """
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "notifyHeightChange", let bodyHeight = message.body as? CGFloat {
            print("Detected body height change: \(bodyHeight)")
        }
    }
}
