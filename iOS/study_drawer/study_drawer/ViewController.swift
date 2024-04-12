//
//  ViewController.swift
//  study_drawer
//
//  Created by Wing CHAN on 12/4/2024.
//

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
        2. iOS 16
        
        """
        let button1 = UIButton(type: .system)
        button1.setTitle("UISheetPresentationController", for: .normal)
        
        let button2 = UIButton(type: .system)
        button2.setTitle("Button 2", for: .normal)
        
        let button3 = UIButton(type: .system)
        button3.setTitle("Button 3", for: .normal)
        
        // Create a stack view
        let stackView = UIStackView(
            arrangedSubviews: [
                label1,
                button1,
                button2,
                button3
            ]
        )
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        ])
        
        // Add targets to buttons
        button1.addTarget(self, action: #selector(button1Tapped), for: .touchUpInside)
        button2.addTarget(self, action: #selector(button2Tapped), for: .touchUpInside)
        button3.addTarget(self, action: #selector(button3Tapped), for: .touchUpInside)
    }
    
    @objc func button1Tapped() {
        let vc = ViewController2()
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.preferredCornerRadius = 0
        }
        vc.modalPresentationStyle = .overFullScreen
        vc.transitioningDelegate = self
        present(vc, animated: true)
    }
    
    @objc func button2Tapped() {
        print("Button 2 was tapped.")
    }
    
    @objc func button3Tapped() {
        print("Button 3 was tapped.")
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting ?? source)
    }
}

class CustomPresentationController: UIPresentationController {
    override var shouldRemovePresentersView: Bool {
        return false
    }
}
