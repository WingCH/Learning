//
//  Animation2ViewController.swift
//  Animation
//
//  Created by Wing CHAN on 29/12/2022.
//

import TinyConstraints
import UIKit

class Animation2ViewController: UIViewController {
    var topPadding: CGFloat!
    var indicatorLayer: CAShapeLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        topPadding = view.safeAreaInsets.top + 100
        
        // 橫線
        let path1 = UIBezierPath()
        let layer1 = CAShapeLayer()
        let startPoint1 = CGPoint(x: view.frame.origin.x, y: view.frame.origin.x + topPadding)
        let endPoint1 = CGPoint(x: view.frame.size.width, y: view.frame.origin.x + topPadding)
        path1.move(to: startPoint1)
        path1.addLine(to: endPoint1)
        layer1.path = path1.cgPath
        layer1.strokeColor = UIColor.red.cgColor
        self.view.layer.addSublayer(layer1)
        
        // 半圓
        let layer2 = CAShapeLayer()
        let path2 = UIBezierPath()
        let center2 = CGPoint(x: view.frame.origin.x + view.frame.size.width / 2, y: view.frame.origin.x + topPadding + 50)
        path2.addArc(withCenter: center2, radius: 50, startAngle: CGFloat.pi, endAngle: 0, clockwise: false)
        layer2.path = path2.cgPath
        layer2.strokeColor = UIColor.red.cgColor
        layer2.fillColor = UIColor.clear.cgColor
        self.view.layer.addSublayer(layer2)
        
        
        // 橫線 + 半圓 + 橫線
        let layer3 = CAShapeLayer()
        let path3 = UIBezierPath()
        let startPoint3 = CGPoint(x: view.frame.origin.x, y: view.frame.origin.x + topPadding + 150)
        let endPoint3 = CGPoint(x: view.frame.size.width, y: view.frame.origin.x + topPadding + 150)
        let radius3: CGFloat = 50
        let center3 = CGPoint(x: (startPoint3.x + endPoint3.x) / 2, y: (startPoint3.y + endPoint3.y) / 2)
        path3.move(to: startPoint3)
        path3.addLine(to: CGPoint(x: center3.x - radius3, y: startPoint3.y))
        path3.addArc(withCenter: center3, radius: radius3, startAngle: CGFloat.pi, endAngle: 0, clockwise: false)
        path3.addLine(to: endPoint3)
        layer3.path = path3.cgPath
        layer3.strokeColor = UIColor.red.cgColor
        layer3.fillColor = UIColor.clear.cgColor
        self.view.layer.addSublayer(layer3)
        
        //
        indicatorLayer = CAShapeLayer()
        self.view.layer.addSublayer(indicatorLayer)
        indicatorLayer.lineWidth = 4
        indicatorLayer.lineCap = .round
        indicatorLayer.fillColor = UIColor.clear.cgColor
        indicatorLayer.strokeColor = UIColor.blue.cgColor
        
        indicatorLayer.path = path3.cgPath
        indicatorLayer.speed = 0.5
        
        indicatorLayer.strokeStart = 0.1
        indicatorLayer.strokeEnd = 0.2
        
        //
        let button = UIButton(type: .system)
        button.setTitle("Go", for: .normal)
        button.addTarget(self, action: #selector(Animation2ViewController.onTap(sender:)), for: .touchUpInside)
        self.view.addSubview(button)
        button.centerInSuperview()
    }

    @objc func onTap(sender: UIButton) {
        indicatorLayer.strokeStart = 0.8
        indicatorLayer.strokeEnd = 0.9
    }
}
