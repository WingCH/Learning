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
    var onTapButton: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        printInfo()

        button.setTitle("Go to second view", for: .normal)
        button.sizeToFit()
        button.center = view.center
        button.addTarget(self, action: #selector(onClickButton), for: .touchUpInside)
        view.addSubview(button)
    }

    @objc private func onClickButton() {
        onTapButton?()
    }

    func printInfo() {
        let log = """
        \(String(describing: ViewControllerC.self)).presentingViewController: \(String(describing: self.presentingViewController))
        \(String(describing: ViewControllerC.self)).presentedViewController: \(String(describing: self.presentedViewController))
        """
        print(log)
    }
}
