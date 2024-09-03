//
//  PresentAnimationController.swift
//  study_custom_navigation_with_push_using_present_animation
//
//  Created by Wing on 3/9/2024.
//

import Foundation
import UIKit

// PresentAnimationController: Custom "present-like" animation
class PresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 // Duration of the animation
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }

        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
        toVC.view.frame = finalFrame.offsetBy(dx: 0, dy: finalFrame.height) // Start position off-screen

        containerView.addSubview(toVC.view)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toVC.view.frame = finalFrame // Animate to final position
        }, completion: { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

// DismissAnimationController: Custom "dismiss-like" animation
class DismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 // Duration of the animation
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }

        let containerView = transitionContext.containerView
        let initialFrame = transitionContext.initialFrame(for: fromVC)
        toVC.view.frame = initialFrame
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromVC.view.frame = initialFrame.offsetBy(dx: 0, dy: initialFrame.height) // Move off-screen
        }, completion: { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

