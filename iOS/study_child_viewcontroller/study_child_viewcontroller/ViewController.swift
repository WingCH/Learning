//
//  ViewController.swift
//  study_child_viewcontroller
//
//  Created by Wing CHAN on 5/7/2023.
//

import UIKit

class ParentViewController: UIViewController {
    private var child1: UIViewController = ChildViewController1()
    private var child2: UIViewController = UINavigationController(rootViewController: ChildViewController2())

    override func viewDidLoad() {
        super.viewDidLoad()

        setupChildren()
        setupButton()
    }

    private func setupChildren() {
        // 預設顯示 child1
        switchToChild(child1)
    }

    private func setupButton() {
        let button = UIButton(type: .system)
        button.setTitle("Switch Child", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(switchChildController), for: .touchUpInside)

        self.view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }

    @objc private func switchChildController() {
        if self.children.contains(child1) {
            switchToChild(child2)
        } else {
            switchToChild(child1)
        }
    }

    private func switchToChild(_ child: UIViewController) {
        self.children.first?.willMove(toParent: nil)
        self.children.first?.view.removeFromSuperview()
        self.children.first?.removeFromParent()

        addChild(child)
        child.view.frame = view.bounds
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
}

class ChildViewController1: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}

class ChildViewController2: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan

        setupButton()
    }

    private func setupButton() {
        let button = UIButton(type: .system)
        button.setTitle("push", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(switchChildController), for: .touchUpInside)

        self.view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }

    @objc private func switchChildController() {
        let vc = ChildViewController3()
        navigationController?.pushViewController(vc, animated: true)
    }
}

class ChildViewController3: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
    }
}
