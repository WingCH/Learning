//
//  ViewController.swift
//  study_member_level_bar
//
//  Created by Wing CHAN on 24/1/2024.
//

import TinyConstraints
import UIKit

class ViewController: UIViewController {
    let memberLevelBar = MemberLevelBar()
    let updateProgressButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(memberLevelBar)
        memberLevelBar.centerInSuperview()
        memberLevelBar.horizontalToSuperview(insets: .horizontal(10))

        view.addSubview(updateProgressButton)
        updateProgressButton.topToBottom(of: memberLevelBar, offset: 20)
        updateProgressButton.centerXToSuperview()
        updateProgressButton.setTitle("Update Progress", for: .normal)
        updateProgressButton.setTitleColor(.blue, for: .normal)
        updateProgressButton.addTarget(self, action: #selector(update), for: .touchUpInside)

        memberLevelBar.configure(
            with: generateDisplayModel(
                levelText: "Level -",
                amountText: "-",
                progress: 0,
                progressBarIsRoundedCorner: true
            )
        )
    }

    @objc func update() {
        memberLevelBar.configure(
            with: generateDisplayModel(
                levelText: "Level \(Int.random(in: 1...10))",
                amountText: "\(Int.random(in: 100...10000))",
                progress: CGFloat.random(in: 0...1),
                progressBarIsRoundedCorner: false
            )
        )
    }

    func generateDisplayModel(levelText: String, amountText: String, progress: CGFloat, progressBarIsRoundedCorner: Bool) -> MemberLevelBar.DisplayModel {
        MemberLevelBar.DisplayModel(
            infoViewGradientColors: [
                // #D8B354
                UIColor(red: 0.846, green: 0.702, blue: 0.331, alpha: 1).cgColor,
                // #A3814F
                UIColor(red: 0.637, green: 0.507, blue: 0.311, alpha: 1).cgColor
            ],
            levelViewBackgroundColor: UIColor(red: 0.2, green: 0.188, blue: 0.173, alpha: 0.3),
            levelViewAttributedText: levelText.toAttributedString(),
            amountAttributedText: amountText.toAttributedString(),
            progress: progress,
            progressViewGradientColors: [
                // #403826
                UIColor(red: 0.251, green: 0.22, blue: 0.149, alpha: 1).cgColor,
                UIColor(red: 0.251, green: 0.22, blue: 0.149, alpha: 1).cgColor
                // #40382600
//                UIColor(red: 0.251, green: 0.22, blue: 0.149, alpha: 0).cgColor
            ],
            progressColor: UIColor(red: 0.78, green: 0.639, blue: 0.325, alpha: 1),
            progressBarIsRoundedCorner: progressBarIsRoundedCorner
        )
    }
}

extension String {
    func toAttributedString(font: UIFont = UIFont.systemFont(ofSize: 14), color: UIColor = UIColor.black) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        return NSAttributedString(string: self, attributes: attributes)
    }
}
