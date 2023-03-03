//
//  ViewController.swift
//  innerShadow
//
//  Created by Wing on 3/3/2023.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let topPadding: CGFloat = 100

        let rect = CGRect(x: 50, y: 100, width: 200, height: 100)
        let layer = CALayer()
        layer.frame = rect
        layer.backgroundColor = UIColor.white.cgColor
        view.layer.addSublayer(layer)

        let innerShadowPath = UIBezierPath(
            roundedRect: rect.offsetBy(dx: -10, dy: 10).insetBy(dx: 10, dy: 10),
            cornerRadius: 0
        )
        let cutout = UIBezierPath(roundedRect: rect, cornerRadius: 0).reversing()
        innerShadowPath.append(cutout)
        let innerShadowLayer = CALayer()
        innerShadowLayer.shadowPath = innerShadowPath.cgPath
        innerShadowLayer.shadowColor = UIColor.yellow.cgColor
        innerShadowLayer.shadowOffset = CGSize(width: -1, height: 0)
        innerShadowLayer.shadowOpacity = 0.5
        innerShadowLayer.shadowRadius = 1

        view.layer.addSublayer(innerShadowLayer)
    }
}
