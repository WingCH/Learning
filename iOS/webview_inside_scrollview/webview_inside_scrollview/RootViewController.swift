//
//  RootViewController.swift
//  webview_inside_scrollview
//
//  Created by Wing on 6/5/2022.
//

import UIKit
import TinyConstraints

class RootViewController: UIViewController {
    
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
        view.addSubview(view1)
        view.addSubview(view2)
    }
    
    fileprivate func constrainSubviews() {
        view.backgroundColor = .white
        
        view1.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        view1.height(100)
        
        view2.topToBottom(of: view1)
        view2.leftToSuperview()
        view2.rightToSuperview()
        view2.height(100)
    }
}
