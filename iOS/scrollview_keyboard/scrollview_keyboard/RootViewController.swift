//
//  RootViewController.swift
//  scrollview_keyboard
//
//  Created by Wing on 18/4/2022.
//

import TinyConstraints
import UIKit

// https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84-swift-ios-app-%E9%96%8B%E7%99%BC%E5%95%8F%E9%A1%8C%E8%A7%A3%E7%AD%94%E9%9B%86/%E5%88%A9%E7%94%A8-contentinset-%E8%AE%93%E9%8D%B5%E7%9B%A4%E5%87%BA%E7%8F%BE%E6%99%82-scroll-view-%E8%87%AA%E5%8B%95%E4%B8%8A%E7%A7%BB-687ab82990f7

class RootViewController: UIViewController {
    let scrollView = UIScrollView()
    let scrollContentView = UIView()
    let contentStackView = UIStackView()

    lazy var textfield1: UITextField = {
        let textfield = UITextField()
        textfield.borderStyle = .roundedRect
        textfield.delegate = self
        return textfield
    }()

    lazy var textfield2: UITextField = {
        let textfield = UITextField()
        textfield.borderStyle = .roundedRect
        textfield.delegate = self
        return textfield
    }()

    lazy var textfield3: UITextField = {
        let textfield = UITextField()
        textfield.borderStyle = .roundedRect
        textfield.delegate = self
        return textfield
    }()

    lazy var textfield4: UITextField = {
        let textfield = UITextField()
        textfield.borderStyle = .roundedRect
        textfield.delegate = self
        return textfield
    }()

    lazy var view1: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()

    lazy var view2: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        registerForKeyboardNotifications()

        view.backgroundColor = .yellow

        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(textfield1)
        contentStackView.addArrangedSubview(textfield2)
        contentStackView.addArrangedSubview(view1)
        contentStackView.addArrangedSubview(textfield3)
        contentStackView.addArrangedSubview(view2)
        contentStackView.addArrangedSubview(textfield4)

        scrollView.edgesToSuperview(usingSafeArea: false)
        scrollContentView.edgesToSuperview()
        scrollContentView.widthToSuperview()

        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        
        contentStackView.edgesToSuperview(insets: .init(top: 8, left: 8, bottom: 0, right: 8))

        view1.height(800)
        view2.height(500)

        // --
//        scrollView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 500, right: 0)
    }

    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWasShown(_ notification: NSNotification) {
        guard let info = notification.userInfo,
              let keyboardFrameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardSize = keyboardFrame.size
        // TODO: why have padding bettween textfield and keyboard
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        print(keyboardSize.height)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    @objc func keyboardWillBeHidden(_: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}

extension RootViewController: UITextFieldDelegate {
    // user presses return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
