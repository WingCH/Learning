//
//  ViewController.swift
//  keyValueView
//
//  Created by Wing CHAN on 13/4/2023.
//

import Then
import TinyConstraints
import UIKit

class ViewController: UIViewController {
    let containerView: UIView = .init()
    let keyValueView: KeyValueView = .init()
    
    let button1: UIButton = .init()
    let button2: UIButton = .init()
    let button3: UIButton = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.do {
            $0.addSubview(containerView.then {
                $0.addSubview(keyValueView)
            })
            $0.addSubview(button1)
            $0.addSubview(button2)
            $0.addSubview(button3)
        }
        
        containerView.do {
            $0.width(250)
            $0.centerXToSuperview()
            $0.centerYToSuperview()
            $0.backgroundColor = .systemGray6
        }
        
        keyValueView.do {
            $0.edgesToSuperview()
        }
        
        button1.do {
            $0.topToBottom(of: containerView, offset: 20)
            $0.centerXToSuperview()
            $0.setTitle("key short, value short", for: .normal)
            $0.backgroundColor = .systemBlue
            $0.setTitleColor(.white, for: .normal)
            $0.addTarget(self, action: #selector(button1Tapped), for: .touchUpInside)
        }
        
        button2.do {
            $0.topToBottom(of: button1, offset: 20)
            $0.centerXToSuperview()
            $0.setTitle("key short, value long", for: .normal)
            $0.backgroundColor = .systemBlue
            $0.setTitleColor(.white, for: .normal)
            $0.addTarget(self, action: #selector(button2Tapped), for: .touchUpInside)
        }
        
        button3.do {
            $0.topToBottom(of: button2, offset: 20)
            $0.centerXToSuperview()
            $0.setTitle("key long, value short", for: .normal)
            $0.backgroundColor = .systemBlue
            $0.setTitleColor(.white, for: .normal)
            $0.addTarget(self, action: #selector(button3Tapped), for: .touchUpInside)
        }
    }
    
    @objc func button1Tapped() {
        keyValueView.config(key: "key", value: "value")
    }

    @objc func button2Tapped() {
        keyValueView.config(key: "key", value: "value value1 value2 value3 value4 value5 value6")
    }

    @objc func button3Tapped() {
        keyValueView.config(key: "key key1 key2 key3 key4 key5 key6", value: "value")
    }
}
