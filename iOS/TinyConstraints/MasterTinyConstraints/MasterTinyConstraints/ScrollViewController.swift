//
//  ScrollViewTest.swift
//  MasterTinyConstraints
//
//  Created by Wing on 17/4/2022.
//

import Foundation

import UIKit
class ScrollViewController: UIViewController {

    let labelOne: UILabel = {
            let label = UILabel()
            label.text = "Scroll Top"
            label.backgroundColor = .red
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        let labelTwo: UILabel = {
            let label = UILabel()
            label.text = "Scroll Bottom"
            label.backgroundColor = .green
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        let scrollView: UIScrollView = {
            let v = UIScrollView()
            v.translatesAutoresizingMaskIntoConstraints = false
            v.backgroundColor = .cyan
            return v
        }()
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // add the scroll view to self.view
            self.view.addSubview(scrollView)
            
            // constrain the scroll view to 8-pts on each side
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0).isActive = true
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0).isActive = true
            
            // add labelOne to the scroll view
            scrollView.addSubview(labelOne)
            
            // constrain labelOne to left & top with 16-pts padding
            // this also defines the left & top of the scroll content
            labelOne.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.0).isActive = true
            labelOne.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16.0).isActive = true
            
            // add labelTwo to the scroll view
            scrollView.addSubview(labelTwo)
            
            // constrain labelTwo at 400-pts from the left
            labelTwo.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 400.0).isActive = true

            // constrain labelTwo at 1000-pts from the top
            labelTwo.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 1000).isActive = true
            
            // constrain labelTwo to right & bottom with 16-pts padding
            labelTwo.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -16.0).isActive = true
            labelTwo.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16.0).isActive = true
            
        }
}
