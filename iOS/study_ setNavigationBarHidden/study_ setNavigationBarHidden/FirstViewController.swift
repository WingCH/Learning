//
//  FirstViewController.swift
//  study_ setNavigationBarHidden
//
//  Created by Wing CHAN on 11/1/2024.
//

import UIKit

class FirstViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let goToSecondVCButton = UIButton(frame: CGRect(x: 100, y: 100, width: 200, height: 50))
        goToSecondVCButton.setTitle("Go to Second VC", for: .normal)
        goToSecondVCButton.setTitleColor(.blue, for: .normal)
        goToSecondVCButton.addTarget(self, action: #selector(goToSecondVC), for: .touchUpInside)
        self.view.addSubview(goToSecondVCButton)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @objc func goToSecondVC() {
        let secondVC = SecondViewController()
        self.navigationController?.pushViewController(secondVC, animated: true)
    }
}
