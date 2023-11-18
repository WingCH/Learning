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
//    private let bottomView = CustomBottomView()
    private let bottomView = CustomBottomStackView()
    private let uiLabel = UILabel()

    var uiLabelBottomConstraint: Constraint?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(button)
        view.addSubview(bottomView)
        view.addSubview(uiLabel)

        button.setTitle("Click", for: .normal)
        button.backgroundColor = .blue
        button.centerInSuperview()
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        uiLabel.centerXToSuperview()
        uiLabel.text = "Label appear above the bottom view"
        uiLabelBottomConstraint = uiLabel.bottomToTop(of: bottomView)

        bottomView.edgesToSuperview(excluding: .top)
        bottomView.onViewExpanded = { expandedHeight in
            self.uiLabelBottomConstraint?.constant = -expandedHeight
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func buttonAction(sender _: UIButton!) {
        bottomView.trigger()
    }
}

// stack
private class CustomBottomStackView: UIView {
    let bottomStack = UIStackView()
    let topStack = UIStackView()
    let uiView1 = UIView()
    let uiView2 = UIView()
    let uiLabel1 = UILabel()
    let uiLabel2 = UILabel()

//    var constraint: Constraint?
    var constraintTop: Constraint?
    var constraintBottom: Constraint?

    var onViewExpanded: ((CGFloat) -> Void)?

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
        wrapper.addSubview(bottomStack)
        wrapper.addSubview(topStack)
        topStack.addArrangedSubview(uiView1)
        topStack.addArrangedSubview(uiView2)
        bottomStack.addArrangedSubview(uiLabel1)
        bottomStack.addArrangedSubview(uiLabel2)

        topStack.axis = .vertical
        bottomStack.axis = .vertical

        uiView1.backgroundColor = .cyan
        uiView1.height(50)
        uiView2.backgroundColor = .darkGray
        uiView2.height(100)

        uiLabel1.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus. Suspendisse lectus tortor, dignissim sit amet, adipiscing nec, ultricies sed, dolor."
        uiLabel1.numberOfLines = 0
        uiLabel1.backgroundColor = .brown

        uiLabel2.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus. Suspendisse lectus tortor, dignissim sit amet, adipiscing nec, ultricies sed, dolor."
        uiLabel2.numberOfLines = 0
        uiLabel2.backgroundColor = .systemGreen

        wrapper.edgesToSuperview()
        topStack.edgesToSuperview()
        bottomStack.horizontalToSuperview()
//        constraint = bottomStack.top(to: topStack)
        constraintTop = bottomStack.top(to: topStack)
        constraintBottom = bottomStack.bottomToTop(of: topStack, isActive: false)
    }

    func trigger() {
        constraintTop?.isActive.toggle()
        constraintBottom?.isActive.toggle()
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()

            if self.constraintBottom?.isActive == true {
                let bottomStackHeight = self.bottomStack.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
                self.onViewExpanded?(bottomStackHeight)
            } else if self.constraintTop?.isActive == true {
                self.onViewExpanded?(0)
            }
        }
    }

    //    func trigger() {
    //        let height: CGFloat
    //        let bottomStackHeight = bottomStack.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    //        let topStackHeight = topStack.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    //
    //        if constraint?.constant == 0 {
    //            constraint?.constant = -bottomStackHeight
    //            height = bottomStackHeight
    //        } else {
    //            constraint?.constant = 0
    //            height = 0
    //        }
    //        UIView.animate(withDuration: 0.5) {
    //            self.layoutIfNeeded()
    //            self.onViewExpanded?(height)
    //        }
    //    }
}

// normal
// private class CustomBottomView: UIView {
//    let topView = UIView()
//    let bottomView = UIView()
//    var constraint: Constraint?
//
//    override init(frame: CGRect = .zero) {
//        super.init(frame: frame)
//        setupViews()
//    }
//
//    @available(*, unavailable)
//    required init?(coder _: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupViews() {
//        let wrapper = UIView()
//        addSubview(wrapper)
//        wrapper.addSubview(bottomView)
//        wrapper.addSubview(topView)
//        wrapper.edgesToSuperview()
//
//        topView.edgesToSuperview()
//        topView.backgroundColor = .red
//        topView.height(100)
//
//        bottomView.horizontalToSuperview()
//        bottomView.backgroundColor = .blue
//        bottomView.height(150)
//        constraint = bottomView.top(to: topView)
//    }
//
//    func trigger() {
//        if constraint?.constant == 0 {
//            constraint?.constant = -bottomView.frame.height
//        } else {
//            constraint?.constant = 0
//        }
//        UIView.animate(withDuration: 0.5) {
//            self.layoutIfNeeded()
//        }
//    }
// }
