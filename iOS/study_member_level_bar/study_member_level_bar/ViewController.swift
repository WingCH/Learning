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
        updateProgressButton.addTarget(self, action: #selector(updateProgress), for: .touchUpInside)
    }
    
    @objc func updateProgress() {
        memberLevelBar.updateProgress(to: CGFloat.random(in: 0...1))
    }
}
