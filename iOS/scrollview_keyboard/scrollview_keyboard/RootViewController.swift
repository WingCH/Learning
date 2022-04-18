//
//  RootViewController.swift
//  scrollview_keyboard
//
//  Created by Wing on 18/4/2022.
//

import UIKit
import TinyConstraints

class RootViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let scrollContentView = UIView()
    let contentStackView = UIStackView()
    
    lazy var textfield1 : UITextField = {
        let textfield = UITextField()
        textfield.borderStyle = .roundedRect
        return textfield;
    }()
    
    lazy var textfield2 : UITextField = {
        let textfield = UITextField()
        textfield.borderStyle = .roundedRect
        return textfield;
    }()
    
    lazy var textfield3 : UITextField = {
        let textfield = UITextField()
        textfield.borderStyle = .roundedRect
        return textfield;
    }()
    
    lazy var textfield4 : UITextField = {
        let textfield = UITextField()
        textfield.borderStyle = .roundedRect
        return textfield;
    }()
    
    
    lazy var view1 : UIView = {
        let view = UIView()
        view.backgroundColor = .red;
        return view;
    }()
    
    lazy var view2 : UIView = {
        let view = UIView()
        view.backgroundColor = .blue;
        return view;
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(textfield1)
        contentStackView.addArrangedSubview(textfield2)
        contentStackView.addArrangedSubview(view1)
        contentStackView.addArrangedSubview(textfield3)
        contentStackView.addArrangedSubview(view2)
        contentStackView.addArrangedSubview(textfield4)
        
        scrollView.edgesToSuperview()
        scrollContentView.edgesToSuperview()
        scrollContentView.widthToSuperview()

        contentStackView.axis = .vertical
        contentStackView.spacing = 32
        contentStackView.edgesToSuperview(insets: .init(top: 8, left: 8, bottom: 100, right: 8))
        
        view1.height(200)
        view2.height(1000)

    }
}

