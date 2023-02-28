//
//  ViewController.swift
//  label-font
//
//  Created by Wing on 26/2/2023.
//

import Then
import TinyConstraints
import UIKit

class ViewController: UIViewController {
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView

    }()

    let englishLabel: UILabel = .init()
    let chineseLabel: UILabel = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.do {
            $0.addSubview(stackView.then {
                $0.addArrangedSubview(englishLabel)
                $0.addArrangedSubview(chineseLabel)
            })
        }

        stackView.do {
            $0.width(100)
            $0.centerInSuperview()
        }

        englishLabel.do {
            $0.text = "Hello World!"
            $0.font = UIFont.systemFont(ofSize: 16)
            $0.numberOfLines = 0
        }

        chineseLabel.do {
            $0.text = "你好世界!"
            $0.font = UIFont.systemFont(ofSize: 16)
            $0.numberOfLines = 0
        }

        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        print("englishLabel view height: \(englishLabel.frame.height)")
        print("englishLabel font height: \(englishLabel.font.lineHeight)")

        print("chineseLabel view height: \(chineseLabel.frame.height)")
        print("chineseLabel font height: \(chineseLabel.font.lineHeight)")
    }
}
