//
//  File.swift
//  learning-then
//
//  Created by Wing on 9/4/2022.
//

import UIKit

class MainSceneDelegate: NSObject, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            window = UIWindow(windowScene: windowScene)

            let vc = MainViewController()
            window?.rootViewController = vc

            window?.makeKeyAndVisible()
        }
    }
}
