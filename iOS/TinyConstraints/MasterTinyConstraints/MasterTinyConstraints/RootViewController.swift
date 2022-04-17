//
//  RootViewController.swift
//  MasterTinyConstraints
//
//  Created by Wing on 3/4/2022.
//

import UIKit

class RootViewController: UIViewController {
    let view0 = TinyView(backgroundColor: #colorLiteral(red: 0.1294117647, green: 0.5882352941, blue: 0.9529411765, alpha: 1), cornerRadius: 0, borderWidth: 0)
    let view1 = TinyView(backgroundColor: #colorLiteral(red: 0.1294117647, green: 0.5882352941, blue: 0.9529411765, alpha: 1))
    let view2 = TinyView(backgroundColor: #colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 1))
    let view3 = TinyView(backgroundColor: #colorLiteral(red: 1, green: 0.5960784314, blue: 0, alpha: 1))
    let view4 = TinyView(backgroundColor: #colorLiteral(red: 0.6117647059, green: 0.1529411765, blue: 0.6901960784, alpha: 1))
    let view5 = TinyView(backgroundColor: #colorLiteral(red: 0.9568627451, green: 0.262745098, blue: 0.2117647059, alpha: 1))

    lazy var oldConstraints = view1.size(CGSize(width: 100, height: 100), isActive: false)
    lazy var newConstraints = view1.size(CGSize(width: 300, height: 300), isActive: false)
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmodtempor incididunt ut Labore et dolore magna aliqua. ut enim ad minim veniam, quisnostrud exercitation ulLamco Laboris nisi ut aliquip ex ea commodo consequat. Duisaute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiatnulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa quiofficia deserunt mollit anim id est Laborum."
        label.numberOfLines = 0;
        return label;
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
        setupViews()
    }
}
