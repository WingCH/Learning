//
//  CustomNavigationControllerDelegate.swift
//  study_custom_navigation_with_push_using_present_animation
//
//  Created by Wing on 3/9/2024.
//

import Foundation
import UIKit

class CustomNavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        if operation == .push, toVC is ViewControllerC {
            return PresentAnimationController() // Use present-like animation for push to C
        } else if operation == .pop, fromVC is ViewControllerC {
            return DismissAnimationController() // Use dismiss-like animation for pop from C
        }
        return nil
    }
}
