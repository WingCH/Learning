//
//  ViewController.swift
//  UILabel_NBSP
//
//  Created by Wing on 19/1/2023.
//

import TinyConstraints
import UIKit

class ViewController: UIViewController {
    let labelA: UILabel = {
        let label: UILabel = .init()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()

    let labelB: UILabel = {
        let label: UILabel = .init()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()

    let labelC: UILabel = {
        let label: UILabel = .init()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let contentView: UIView = .init()
        view.addSubview(contentView)
        contentView.width(110)
        contentView.height(150)
        contentView.centerInSuperview()
        contentView.backgroundColor = UIColor.yellow.withAlphaComponent(0.8)

        contentView.addSubview(labelA)
        contentView.addSubview(labelB)
        contentView.addSubview(labelC)

        labelA.topToSuperview()
        labelA.leftToSuperview()
        labelA.rightToSuperview()
        labelA.attributedText = createAttrString(key: "product", value: "macbook")

        labelB.topToBottom(of: labelA)
        labelB.leftToSuperview()
        labelB.rightToSuperview()
        labelB.attributedText = createAttrString(key: "product", value: "macbook pro m2")

        labelC.topToBottom(of: labelB)
        labelC.leftToSuperview()
        labelC.rightToSuperview()
        labelC.attributedText = createAttrString(key: "product", value: "macbook pro m2 pro")
    }

    private func createAttrString(key: String, value: String) -> NSAttributedString {
        let attrStr: NSMutableAttributedString = NSMutableAttributedString()
        attrStr.append(
            NSAttributedString(string: "\(key): ", attributes: [
                .font: UIFont.systemFont(ofSize: 12),
            ])
        )

        let v: String = value
        attrStr.append(
            NSAttributedString(string: v, attributes: [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.systemRed,
            ])
        )
        return attrStr
    }
}
