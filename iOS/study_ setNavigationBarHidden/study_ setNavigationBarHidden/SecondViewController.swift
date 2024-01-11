//
//  SecondViewController.swift
//  study_ setNavigationBarHidden
//
//  Created by Wing CHAN on 11/1/2024.
//

import Foundation
import UIKit

class SecondViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .lightGray
        // 在此處添加 SecondViewController 的其他設定
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

}
