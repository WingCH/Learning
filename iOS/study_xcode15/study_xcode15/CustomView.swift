//
//  CustomView.swift
//  study_xcode15
//
//  Created by Wing on 7/6/2023.
//

import UIKit
import TinyConstraints

public class View1: UIView {
    init() {
        super.init(frame: .zero)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .red
    }
}

#Preview {
    let view = UIView()
    view.size(.init(width: 100, height: 100))
    let subview = View1()
    view.addSubview(subview)
    subview.edgesToSuperview()
    return view
}
