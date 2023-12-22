//
//  ViewController.swift
//  study_KeyboardLayoutGuide
//
//  Created by Wing on 22/12/2023.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var textfield: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onReturnButtonClicked(_ sender: Any) {
        self.view.endEditing(true)
    }
}
