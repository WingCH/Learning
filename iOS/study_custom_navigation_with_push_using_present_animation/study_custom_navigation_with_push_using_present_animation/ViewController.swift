//
//  ViewController.swift
//  study_custom_navigation_with_push_using_present_animation
//
//  Created by Wing on 3/9/2024.
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

class ViewControllerB: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        title = "ViewController B"

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
