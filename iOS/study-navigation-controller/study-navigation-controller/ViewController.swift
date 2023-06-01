//
//  ViewController.swift
//  study-navigation-controller
//
//  Created by Wing on 1/6/2023.
//

import UIKit

class ViewController: UIViewController {
    let button = UIButton(type: .system)
    
    var onTapButton: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.setTitle("Go to second view", for: .normal)
        button.sizeToFit()
        button.center = view.center
        button.addTarget(self, action: #selector(onClickButton), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc private func onClickButton() {
        onTapButton?()
    }
}
