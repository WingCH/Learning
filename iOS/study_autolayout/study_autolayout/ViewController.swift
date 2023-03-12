//
//  ViewController.swift
//  study_autolayout
//
//  Created by Wing on 12/3/2023.
//  https://juejin.cn/post/7020398696848179207

import Then
import TinyConstraints
import UIKit

class CustomView: UIView {
    var c: Constraints?
    var label: UILabel = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        c = size(.init(width: 100, height: 100))

        label.text = "text"
        addSubview(label)
        label.centerInSuperview()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        super.updateConstraints()
        print(#function)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        print(#function)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        print(#function)
    }

    func updateSize(width: Int, height: Int) {
        c?.deActivate()
        c = size(.init(width: width, height: height))
    }
}

class ViewController: UIViewController {
    let customView: CustomView = .init()
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)

        view.addSubview(customView)
        customView.do {
            $0.centerInSuperview()
            $0.backgroundColor = .red
        }
    }
}
