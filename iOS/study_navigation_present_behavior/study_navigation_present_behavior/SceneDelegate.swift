//
//  SceneDelegate.swift
//  study_navigation_present_behavior
//
//  Created by Wing on 19/4/2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions)
    {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        
        let vcA = ViewControllerA()
        let vcB = ViewControllerB()
        let nav = UINavigationController()
        nav.setViewControllers([vcA, vcB], animated: true)
        window.rootViewController = nav
        
//        let vcB = ViewControllerB()
//        vcA.present(vcB, animated: true)
        self.window = window
        window.makeKeyAndVisible()
    }
}
