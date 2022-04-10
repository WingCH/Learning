//
//  ViewController.swift
//  alert-show-once
//
//  Created by CHAN Hong Wing on 19/12/2020.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func onClick(_ sender: Any) {
        showAlert()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
            showAlert()
        }
    }
    
    func showAlert(){
        let alertController = UIAlertController(title: "Error", message: "message", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: { _ in
            print("closed")
        }))
        alertController.presentInOwnWindow(showOnceOnly: true, animated: true, completion: nil)
    }
}


extension UIAlertController {
    func presentInOwnWindow(showOnceOnly: Bool, animated: Bool, completion: (() -> Void)?) {
        
        let windowAlertPresentationController = WindowAlertPresentationController(alert: self)
        windowAlertPresentationController.present(showOnceOnly: showOnceOnly, animated: animated, completion: completion)
    }
}
