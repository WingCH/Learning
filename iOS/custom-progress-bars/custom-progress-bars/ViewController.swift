//
//  ViewController.swift
//  custom-progress-bars
//
//  Created by Wing on 1/3/2023.
//

import Then
import TinyConstraints
import UIKit

class ProgressBar: UIView {
    var progressColor: UIColor = .red
    private let progressLayer = CALayer()
    private let backgroundMask = CAShapeLayer()
    private let innerShadow = CALayer()

    var progress: CGFloat = 0.0 {
        didSet {
            // trigger `draw`
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(progressLayer)
        layer.addSublayer(innerShadow)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layer.addSublayer(progressLayer)
        layer.addSublayer(innerShadow)
    }

    override func draw(_ rect: CGRect) {
        backgroundMask.path = UIBezierPath(
            roundedRect: rect,
            cornerRadius: rect.height * 0.25
        ).cgPath
        layer.mask = backgroundMask

        // https://stackoverflow.com/a/47791243/5588637
        innerShadow.frame = rect
        let cornerRadius = rect.height * 0.25
        let path = UIBezierPath(roundedRect: innerShadow.bounds.offsetBy(dx: -1, dy: 1).insetBy(dx: 1, dy: 1), cornerRadius: cornerRadius)
        let cutout = UIBezierPath(roundedRect: innerShadow.bounds, cornerRadius: cornerRadius).reversing()

        path.append(cutout)
        innerShadow.shadowPath = path.cgPath
        innerShadow.masksToBounds = true
        innerShadow.shadowColor = UIColor.black.cgColor
        innerShadow.shadowOffset = CGSize(width: -1, height: 0)
        innerShadow.shadowOpacity = 1
        innerShadow.shadowRadius = 1
        innerShadow.cornerRadius = cornerRadius
        
        innerShadow.backgroundColor = UIColor.blue.cgColor

        let progressRect = CGRect(
            origin: .zero,
            size: CGSize(
                width: rect.width * progress,
                height: rect.height
            )
        )
        progressLayer.frame = progressRect
        progressLayer.backgroundColor = progressColor.cgColor
    }
}

class ViewController: UIViewController {
    let progressBar: ProgressBar = .init()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.do {
            $0.addSubview(progressBar)
        }

        progressBar.do {
            $0.width(250)
            $0.height(50)
            $0.centerInSuperview()
            $0.backgroundColor = .gray
        }

        // timer update progress
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.progressBar.progress += 0.01
        }
    }
}
