//
//  File.swift
//  learning-then
//
//  Created by Wing on 9/4/2022.
//

import Foundation
import Then
import UIKit

class MainViewController: UIViewController {
    let titleLabel = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .center
    }

    /*
     let label: UILabel = {
       let label = UILabel()
       label.textAlignment = .center
       label.textColor = .black
       label.text = "Hello, World!"
       return label
     }()
     */

    override func viewDidLoad() {
        super.viewDidLoad()

//        view.do {
//            $0.backgroundColor = .yellow
//            $0.addSubview(titleLabel)
//        }

        view.backgroundColor = .yellow
        view.addSubview(titleLabel)

//        titleLabel.do {
//            $0.text = "Hello, `Then`"
//            $0.translatesAutoresizingMaskIntoConstraints = false
//            $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//            $0.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        }

        titleLabel.text = "Hello, `Then`"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
