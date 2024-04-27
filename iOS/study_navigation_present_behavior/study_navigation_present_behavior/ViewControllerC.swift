//
//  ViewControllerC.swift
//  study_navigation_present_behavior
//
//  Created by Wing on 19/4/2024.
//

import UIKit

class ViewControllerC: UIViewController {
    var isFirstAppear = true
    let button = UIButton(type: .system)
    var onPopLastNavigationPage: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        printInfo()

        button.setTitle("pop last navigation page", for: .normal)
        button.sizeToFit()
        button.center = view.center
        button.addTarget(self, action: #selector(onClickButton), for: .touchUpInside)
        view.addSubview(button)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("\(String(describing: ViewControllerC.self)) viewDidAppear")
    }

    @objc private func onClickButton() {
        onPopLastNavigationPage?()
        dismiss(animated: true)
    }

    func printInfo() {
        let log = """
        \(String(describing: ViewControllerC.self)).presentingViewController: \(String(describing: self.presentingViewController))
        \(String(describing: ViewControllerC.self)).presentedViewController: \(String(describing: self.presentedViewController))
        """
        print(log)
    }
}
