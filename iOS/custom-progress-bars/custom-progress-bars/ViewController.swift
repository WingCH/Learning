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
    var progress: CGFloat = 0.0 {
        didSet {
            // trigger `draw`
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(progressLayer)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layer.addSublayer(progressLayer)
    }

    override func draw(_ rect: CGRect) {
        backgroundMask.path = UIBezierPath(
            roundedRect: rect,
            cornerRadius: rect.height * 0.25
        ).cgPath
        layer.mask = backgroundMask

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
