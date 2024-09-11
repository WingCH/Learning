//
//  ViewController.swift
//  study_custom_push_animation
//
//  Created by Wing CHAN on 3/9/2024.
//

import UIKit

class ViewControllerA: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "ViewController A"

        let pushButton = UIButton(type: .system)
        pushButton.setTitle("Push to B", for: .normal)
        pushButton.addTarget(self, action: #selector(pushToB), for: .touchUpInside)
        pushButton.frame = CGRect(x: 100, y: 200, width: 200, height: 50)
        view.addSubview(pushButton)
    }

    @objc func pushToB() {
        let viewControllerB = ViewControllerB()
        navigationController?.pushViewController(viewControllerB, animated: true)
    }
}

class ViewControllerB: UIViewController, UINavigationControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        title = "ViewController B"
        navigationController?.delegate = self

        let pushButton = UIButton(type: .system)
        pushButton.setTitle("Push to C with Present Animation", for: .normal)
        pushButton.addTarget(self, action: #selector(pushToC), for: .touchUpInside)
        pushButton.frame = CGRect(x: 50, y: 200, width: 300, height: 50)
        view.addSubview(pushButton)
    }

    @objc func pushToC() {
        let viewControllerC = ViewControllerC()
        navigationController?.pushViewController(viewControllerC, animated: true)
    }
    
    // 設定自定義動畫
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push, toVC is ViewControllerC {
            return PresentAnimationController()
        } else if operation == .pop, fromVC is ViewControllerC {
            return DismissAnimationController()
        }
        return nil
    }
}

class ViewControllerC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan
        title = "ViewController C"
        
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back to B", for: .normal)
        backButton.addTarget(self, action: #selector(popToB), for: .touchUpInside)
        backButton.frame = CGRect(x: 100, y: 200, width: 200, height: 50)
        view.addSubview(backButton)
    }

    @objc func popToB() {
        navigationController?.popViewController(animated: true)
    }
}


class PresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 // 設置動畫持續時間
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
        toVC.view.frame = finalFrame.offsetBy(dx: 0, dy: finalFrame.height) // 初始位置在螢幕下方

        containerView.addSubview(toVC.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toVC.view.frame = finalFrame // 動畫過程中將toVC的view移動到最終位置
        }, completion: { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

class DismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 // 動畫持續時間
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
            fromVC.view.frame = initialFrame.offsetBy(dx: 0, dy: initialFrame.height) // 移動到螢幕下方
        }, completion: { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
