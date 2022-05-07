//
//  RootViewController.swift
//  webview_inside_scrollview
//
//  Created by Wing on 6/5/2022.
//

import UIKit
import TinyConstraints

class RootViewController: UIViewController {
    
    let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.backgroundColor = .cyan
        return v
    }()
    
    let scrollContentView = UIView()
    let contentStackView = UIStackView()
    
    let view1: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    let view2: UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        constrainSubviews()
    }
    
    fileprivate func addSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(view1)
        contentStackView.addArrangedSubview(view2)
    }
    
    fileprivate func constrainSubviews() {
        view.backgroundColor = .white
        
        scrollView.edgesToSuperview()
        scrollContentView.edgesToSuperview()
        scrollContentView.widthToSuperview()
        
        contentStackView.axis = .vertical
        contentStackView.edgesToSuperview()
        
        view1.height(100)
        
        view2.widthToSuperview()
        view2.height(1000)
    }
}
