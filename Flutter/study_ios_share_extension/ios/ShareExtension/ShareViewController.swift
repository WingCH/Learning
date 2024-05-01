//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Wing on 1/5/2024.
//

import Flutter
import UIKit

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        showFlutter()
    }

    func showFlutter() {
        view.backgroundColor = .red
        let flutterViewController = FlutterViewController(project: nil, nibName: nil, bundle: nil)
        addChild(flutterViewController)
        view.addSubview(flutterViewController.view)
        flutterViewController.view.frame = view.bounds
    }
}
