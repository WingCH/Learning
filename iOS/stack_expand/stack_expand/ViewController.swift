//
//  ViewController.swift
//  stack_expand
//
//  Created by Wing CHAN on 17/11/2023.
//

import TinyConstraints
import UIKit

class ViewController: UIViewController {
    let customView = CustomView()
    // add a button in center
    let button = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(button)
        view.addSubview(customView)

        button.setTitle("Click", for: .normal)
        button.backgroundColor = .blue
        button.centerInSuperview()
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        customView.edgesToSuperview(excluding: .top)
    }

    @objc func buttonAction(sender _: UIButton!) {
        self.customView.test()
    }
}

class CustomView: UIView {
    let wrapper = UIView()

    let bottomStack = UIStackView()
    let topStack = UIStackView()
    let uiView1 = UIView()
    let uiView2 = UIView()
    let uiView3 = UIView()
    let uiView4 = UIView()

    var isTransformed: Bool = false
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

        bottomStack.axis = .vertical
        topStack.axis = .vertical

        uiView1.backgroundColor = .cyan
        uiView1.height(50)
        uiView2.backgroundColor = .darkGray
        uiView2.height(150)

        bottomStack.addArrangedSubview(uiView1)
        bottomStack.addArrangedSubview(uiView2)

        uiView3.height(50)
        uiView3.backgroundColor = .brown

        uiView4.height(50)
        uiView4.backgroundColor = .blue

        topStack.addArrangedSubview(uiView3)
        topStack.addArrangedSubview(uiView4)

        addSubview(bottomStack)
        addSubview(topStack)

        bottomStack.edgesToSuperview(excluding: .bottom)
        topStack.edgesToSuperview(excluding: .top)
        bottomStack.top(to: topStack)
    }

    func test() {
        let stack1Height = bottomStack.frame.height
        if isTransformed {
            isTransformed = false
            UIView.animate(withDuration: 1.0) {
                self.bottomStack.transform = .identity
            }
        } else {
            isTransformed = true
            UIView.animate(withDuration: 1.0) {
                self.bottomStack.transform = CGAffineTransform(translationX: 0, y: -stack1Height)
            }
        }
    }
}
