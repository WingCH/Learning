//
//  ViewController.swift
//  study_textfield
//
//  Created by Wing CHAN on 7/6/2023.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    // 定義文字輸入框
    var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let text = "1234 "
        
        let range1 = NSRange(location: 1, length: 1)
        if let range = Range(range1, in: text) {
            // to string
            print(range)
            print(text[range])
        }else {
            print("error")
        }
       
        
        
        // 初始化文字輸入框
        textField = UITextField(frame: CGRect(x: 50, y: 100, width: 300, height: 40))
        textField.backgroundColor = .lightGray
        textField.delegate = self
        view.addSubview(textField)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }

    // MARK: - UITextFieldDelegate 方法

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("shouldChangeCharactersIn")
        print("original textfield: \(textField.text ?? "")")
        print("range: \(range)")
        print("replacementString: \(string)")
        print("------------")
        if let newPosition = textField.position(from: textField.beginningOfDocument, offset: 1) {
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
        return true
    }

    // MARK: - 在點擊空白處隱藏鍵盤

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


