//
//  RootViewController+SetupVIews.swift
//  MasterTinyConstraints
//
//  Created by Wing on 3/4/2022.
//

import TinyConstraints

extension RootViewController {
    func setupViews() {
        addSubViews()
        constrainSubviews()
    }

    fileprivate func addSubViews() {
//        view.addSubview(view1)
//        view.addSubview(view2)
//        view.addSubview(view3)
//        view.addSubview(view4)
//        view.addSubview(view5)
    }

    fileprivate func constrainSubviews() {
//        view1.originToSuperview(insets: TinyEdgeInsets(top: 16, left: 16, bottom: 0, right: 0), usingSafeArea: true)
//        oldConstraints.activate()
//
//        oldConstraints.deActivate()
//        newConstraints.activate()
//        UIViewPropertyAnimator(duration: 5, dampingRatio: 0.4) {
//            self.view.layoutIfNeeded()
//        }.startAnimation()

//        view1.edgesToSuperview(excluding: .bottom, insets: .uniform(12), usingSafeArea: true)
//        view1.height(500)
//
//        view2.edges(to: view1, excluding: .right, insets: .zero)
//        view2.width(100, relation: .equalOrGreater)
//
//        view3.edges(to: view1, excluding: .left)
//        view3.width(50)
//        view3.leftToRight(of: view2, offset: 12)

//        view2.height(100)
//        view3.height(200, relation: .equalOrGreater)
//        view1.stack([view2, view3], axis: .vertical, spacing: 20)

//        view2.height(100)
//        view1.stack([view2, label], axis: .vertical, spacing: 10)

//        view.addSubview(view1)
//        view.addSubview(view2)

        let scrollView = UIScrollView()
        let scrollContentView = UIView()
        let contentStackView = UIStackView()
        lazy var view1: UIView = {
            let view = UIView()
            view.backgroundColor = .blue
            return view
        }()

        lazy var view2: UIView = {
            let view = UIView()
            view.backgroundColor = .red
            return view
        }()

        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(view1)
        contentStackView.addArrangedSubview(view2)

        scrollView.edgesToSuperview()
        scrollContentView.edgesToSuperview()
        scrollContentView.widthToSuperview()

        contentStackView.axis = .vertical
        contentStackView.spacing = 32
        contentStackView.edgesToSuperview(insets: .init(top: 8, left: 8, bottom: 100, right: 8))

        view1.height(200)
        view2.height(1500)
    }
}
