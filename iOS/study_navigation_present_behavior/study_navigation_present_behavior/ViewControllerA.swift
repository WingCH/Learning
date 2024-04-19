//
//  ViewController.swift
//  study_navigation_present_behavior
//
//  Created by Wing on 19/4/2024.
//

import UIKit

class ViewControllerA: UIViewController {
    var isFirstAppear = true
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstAppear {
            isFirstAppear = false
            let vcB = ViewControllerB()
            navigationController?.pushViewController(vcB, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.printInfo()
            }
//            present(vcB, animated: true) {
//                self.printInfo()
//            }
        }
    }

    func printInfo() {
        let log = """
        \(String(describing: ViewControllerA.self)).presentingViewController: \(String(describing: self.presentingViewController))
        \(String(describing: ViewControllerA.self)).presentedViewController: \(String(describing: self.presentedViewController))
        """
        print(log)
    }
}
