//
//  RootViewController.swift
//  webview_inside_scrollview
//
//  Created by Wing on 6/5/2022.
//

import TinyConstraints
import UIKit
import WebKit

class RootViewController: UIViewController {
    let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.backgroundColor = .cyan
        return v
    }()

    let scrollContentView = UIView()
    let contentStackView = UIStackView()

    let view1: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()

    let view2: UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        return view
    }()

    let webView = WKWebView()
    var webViewHeightConstraint: Constraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        constrainSubviews()

        webView.navigationDelegate = self
    }

    fileprivate func addSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(view1)
        contentStackView.addArrangedSubview(view2)
        contentStackView.addArrangedSubview(webView)
    }

    fileprivate func constrainSubviews() {
        view.backgroundColor = .white

        scrollView.edgesToSuperview()

        scrollContentView.backgroundColor = .green
        scrollContentView.edgesToSuperview()
        scrollContentView.widthToSuperview()

        contentStackView.backgroundColor = .gray
        contentStackView.axis = .vertical
        contentStackView.edgesToSuperview()

        view1.height(100)
        view2.height(1500)
        webViewHeightConstraint = webView.height(200)

        if let url = URL(string: "https://wingch.site/content/iOS/WidgetsKit%20Transparent%20background.html") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

// https://stackoverflow.com/a/54276004/5588637
extension RootViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.webViewHeightConstraint?.constant = webView.scrollView.contentSize.height
        }
    }
}
