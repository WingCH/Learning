//
//  SceneDelegate.swift
//  stack_expand
//
//  Created by Wing CHAN on 17/11/2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIViewExpandViewController()
        self.window = window
        window.makeKeyAndVisible()
    }
} 
