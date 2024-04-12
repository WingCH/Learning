//
//  ViewController.swift
//  study_present_detect_dismiss
//
//  Created by Wing on 21/3/2024.
//

import UIKit

class DismissSegue: UIStoryboardSegue {
    override func perform() {
        self.source.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

// https://stackoverflow.com/questions/32853212/detect-when-a-presented-view-controller-is-dismissed/78200898#78200898
class ViewController: UIViewController {
    var observation: NSKeyValueObservation?
    override func viewDidLoad() {
        super.viewDidLoad()

        observation = observe(\.presentationController, options: [.old, .new]) { _, change in
            print("presentationController changed")
            if let vc = change.newValue as? UIPresentationController {
                print("presentedViewController: \(vc.presentedViewController.presentedViewController)")
            }
        }
    }

    deinit {
        observation?.invalidate()
    }
}
