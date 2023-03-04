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
        
        let layer1 = CALayer()
        layer1.frame = rect
        layer1.backgroundColor = UIColor.white.cgColor
        view.layer.addSublayer(layer1)
        
        let layer2 = CALayer()
        layer2.frame = rect.offsetBy(dx: -5, dy: 5).insetBy(dx: 5, dy: 5)
        layer2.backgroundColor = UIColor.white.cgColor
        view.layer.addSublayer(layer2)
        
        
        let layer2Path = UIBezierPath(rect: layer2.frame)
        let layer1Path = UIBezierPath(rect: layer1.frame).reversing()
        layer2Path.append(layer1Path)
        
        
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = layer2Path.cgPath
//        shapeLayer.fillColor = UIColor.yellow.cgColor
//        view.layer.addSublayer(shapeLayer)
        
        let innerShadowLayer = CALayer()
        innerShadowLayer.shadowPath = layer2Path.cgPath
        innerShadowLayer.shadowColor = UIColor.yellow.cgColor
        innerShadowLayer.shadowOffset = CGSize(width: -1, height: 0)
        innerShadowLayer.shadowOpacity = 0.5
        innerShadowLayer.shadowRadius = 10
        view.layer.addSublayer(innerShadowLayer)
    }
}
