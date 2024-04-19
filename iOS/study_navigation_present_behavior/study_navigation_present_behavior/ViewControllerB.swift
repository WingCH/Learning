//
//  ViewControllerB.swift
//  study_navigation_present_behavior
//
//  Created by Wing on 19/4/2024.
//

import UIKit

class ViewControllerB: UIViewController {
    var isFirstAppear = true
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstAppear {
            isFirstAppear = false
            let vcC = ViewControllerC()
            present(vcC, animated: true) {
                self.printInfo()
            }
        }
    }

    func printInfo() {
        let log = """
        \(String(describing: ViewControllerB.self)).presentingViewController: \(String(describing: self.presentingViewController))
        \(String(describing: ViewControllerB.self)).presentedViewController: \(String(describing: self.presentedViewController))
        """
        print(log)
    }
}
