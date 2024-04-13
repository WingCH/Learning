//
//  ViewController.swift
//  study_drawer
//
//  Created by Wing CHAN on 12/4/2024.
//

import FloatingPanel
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label1 = UILabel()
        label1.numberOfLines = 0
        label1.text = """
        UISheetPresentationController
        Issue:
        1. cannot disable `presentingViewController` animation when detents is large
        2. Custom Height need iOS 16
        """
        let button1 = UIButton(type: .system)
        button1.setTitle("UISheetPresentationController", for: .normal)
        
        let label2 = UILabel()
        label2.numberOfLines = 0
        label2.text = """
        UIViewControllerTransitioningDelegate
        Issue:
        1. no Drag
        """
        let button2 = UIButton(type: .system)
        button2.setTitle("UIViewControllerTransitioningDelegate -> UIPresentationController", for: .normal)
        
        let label3 = UILabel()
        label3.numberOfLines = 0
        label3.text = """
        FloatingPanel
        """
        let button3 = UIButton(type: .system)
        button3.setTitle("FloatingPanel normal", for: .normal)
        let button4 = UIButton(type: .system)
        button4.setTitle("FloatingPanel IntrinsicView", for: .normal)
        
        // Create a stack view
        let stackView = UIStackView(
            arrangedSubviews: [
                label1,
                button1,
                label2,
                button2,
                label3,
                button3,
                button4,
            ]
        )
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
        ])
        
        // Add targets to buttons
        button1.addTarget(self, action: #selector(button1Tapped), for: .touchUpInside)
        button2.addTarget(self, action: #selector(button2Tapped), for: .touchUpInside)
        button3.addTarget(self, action: #selector(button3Tapped), for: .touchUpInside)
        button4.addTarget(self, action: #selector(button4Tapped), for: .touchUpInside)
    }
    
    @objc func button1Tapped() {
        let vc = ViewController2()
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    @objc func button2Tapped() {
        let vc = ViewController2()
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        present(vc, animated: true, completion: nil)
    }
    
    @objc func button3Tapped() {
        let fpc = FloatingPanelController()
        let contentVC = ViewController2()
        fpc.set(contentViewController: contentVC)
        fpc.contentMode = .fitToBounds
        fpc.isRemovalInteractionEnabled = true
        fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        
        self.present(fpc, animated: true, completion: nil)
    }
    
    @objc func button4Tapped() {
        let fpc = FloatingPanelController()
        let contentVC = IntrinsicViewController()
        fpc.set(contentViewController: contentVC)
        fpc.layout = IntrinsicPanelLayout()
        fpc.behavior = IntrinsicPanelBehavior()
        // tap background to dismiss
        fpc.isRemovalInteractionEnabled = true
        fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        self.present(fpc, animated: true, completion: nil)
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

// https://stackoverflow.com/a/70360369
class PresentationController: UIPresentationController {
    let blurEffectView: UIVisualEffectView!
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
  
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView.isUserInteractionEnabled = true
        self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
    }
  
    override var frameOfPresentedViewInContainerView: CGRect {
        CGRect(origin: CGPoint(x: 0, y: self.containerView!.frame.height * 0.4),
               size: CGSize(width: self.containerView!.frame.width, height: self.containerView!.frame.height *
                   0.6))
    }

    override func presentationTransitionWillBegin() {
        self.blurEffectView.alpha = 0
        self.containerView?.addSubview(blurEffectView)
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.blurEffectView.alpha = 0.7
        }, completion: { _ in })
    }
  
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.blurEffectView.alpha = 0
        }, completion: { _ in
            self.blurEffectView.removeFromSuperview()
        })
    }
  
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView!.roundCorners([.topLeft, .topRight], radius: 22)
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        blurEffectView.frame = containerView!.bounds
    }

    @objc func dismissController() {
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
