//
//  ViewController.swift
//  study_keypath
//
//  Created by Wing on 15/4/2024.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onTap(_ sender: Any) {
        let vc2 = ViewControlle2()
        present(vc2, animated: true)
    }
}
