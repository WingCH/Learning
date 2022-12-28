//
//  Animation1ViewController.swift
//  Animation
//
//  Created by Wing CHAN on 28/12/2022.
//

import TinyConstraints
import UIKit

class Animation1ViewController: UIViewController {
    var view1: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .blue
        return view
    }()

    var sizeConstraint: Constraint?
    let smallSize: CGFloat = 150
    let largeSize: CGFloat = 250

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
        view1.addGestureRecognizer(gesture)

        view.addSubview(view1)
        sizeConstraint = view1.width(smallSize)
        view1.aspectRatio(1)
        view1.centerInSuperview()
    }

    @objc func onTap(_ sender: UITapGestureRecognizer) {
//        UIView.animate(withDuration: 0.2) { [weak self] in
//            guard let self else { return }
//            if let constant = self.sizeConstraint?.constant,
//               constant == self.smallSize
//            {
//                self.sizeConstraint?.constant = self.largeSize
//            } else {
//                self.sizeConstraint?.constant = self.smallSize
//            }
//            self.view.layoutIfNeeded()
//        }

        UIViewPropertyAnimator(duration: 1, dampingRatio: 0.4) { [weak self] in
            guard let self else { return }
            if let constant = self.sizeConstraint?.constant,
               constant == self.smallSize
            {
                self.sizeConstraint?.constant = self.largeSize
            } else {
                self.sizeConstraint?.constant = self.smallSize
            }
            self.view.layoutIfNeeded()
        }.startAnimation()
    }
}

