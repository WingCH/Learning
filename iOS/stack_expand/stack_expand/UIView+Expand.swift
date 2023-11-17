//
//  UIView+Expand.swift
//  stack_expand
//
//  Created by Wing on 17/11/2023.
//

import Foundation
import TinyConstraints
import UIKit

class UIViewExpandViewController: UIViewController {
    let button = UIButton()
    private let bottomView = CustomBottomView()

    var constraint: Constraint?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(button)
        view.addSubview(bottomView)

        button.setTitle("Click", for: .normal)
        button.backgroundColor = .blue
        button.centerInSuperview()
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        bottomView.edgesToSuperview(excluding: .top)
    }

    @objc func buttonAction(sender _: UIButton!) {
        bottomView.trigger()
    }
}

private class CustomBottomView: UIView {
    let topView = UIView()
    let bottomView = UIView()
    var constraint: Constraint?

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        let wrapper = UIView()
        addSubview(wrapper)
        wrapper.addSubview(bottomView)
        wrapper.addSubview(topView)
        wrapper.edgesToSuperview()

        topView.edgesToSuperview()
        topView.backgroundColor = .red
        topView.height(100)

        bottomView.horizontalToSuperview()
        bottomView.backgroundColor = .blue
        bottomView.height(150)
        constraint = bottomView.top(to: topView)
    }

    func trigger() {
        if constraint?.constant == 0 {
            constraint?.constant = -bottomView.frame.height
        } else {
            constraint?.constant = 0
        }
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
        }
    }
}
