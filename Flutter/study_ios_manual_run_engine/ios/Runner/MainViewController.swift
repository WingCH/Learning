//
//  MainViewController.swift
//  Runner
//
//  Created by Wing on 30/6/2024.
//

import Flutter
import Foundation
import UIKit

class MainViewController: FlutterViewController {
    var flutterEngine: FlutterEngine?
    var backgroundChannel: FlutterMethodChannel?

    // native button
    lazy var nativeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Native Button", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(nativeButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // add native button
        view.addSubview(nativeButton)
        nativeButton.translatesAutoresizingMaskIntoConstraints = false
        // left bottom
        NSLayoutConstraint.activate([
            nativeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            nativeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nativeButton.widthAnchor.constraint(equalToConstant: 200),
            nativeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func nativeButtonTapped() {
        // get callback handle for userdefaults
        let callbackHandle = UserDefaults.standard.integer(forKey: "callbackHandle")
        guard let flutterCallbackInformation = FlutterCallbackCache.lookupCallbackInformation(Int64(callbackHandle)) else {
            print("Native: Flutter callback information not found")
            return
        }
        print("Native: Create flutter engine")
        flutterEngine = FlutterEngine(
            name: "com.wingch.flutter.engine.prefix",
            project: nil,
            allowHeadlessExecution: true
        )

        guard let flutterEngine = flutterEngine else {
            print("Native: Flutter engine not found")
            return
        }

        print("Native: Run flutter engine with callback information: \(flutterCallbackInformation)")
        flutterEngine.run(
            withEntrypoint: flutterCallbackInformation.callbackName,
            libraryURI: flutterCallbackInformation.callbackLibraryPath
        )

        // TODO: PluginRegistrant
        GeneratedPluginRegistrant.register(with: flutterEngine)

        backgroundChannel = FlutterMethodChannel(
            name: "samples.flutter.dev/backgroundChannel",
            binaryMessenger: flutterEngine.binaryMessenger
        )

        print("Native: Invoke flutter method  in background channel")
        backgroundChannel?.invokeMethod(
            "waitResult",
            arguments: nil,
            result: { [weak self] flutterResult in
                self?.cleanupFlutterResources()
                print("Native: Flutter result: \(flutterResult), Date: \(Date())")
            }
        )
    }

    func cleanupFlutterResources() {
        flutterEngine?.destroyContext()
        backgroundChannel = nil
        flutterEngine = nil
    }
}
