//
//  ViewController.swift
//  study_hittest
//
//  Created by Wing CHAN on 4/10/2023.
//

import UIKit

class ViewController: UIViewController {
    private let customControl = CustomControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        customControl.addTarget(self, action: #selector(customControlTapped), for: .touchUpInside)
        customControl.backgroundColor = .red
        customControl.onTapUrl = { url in
            print("url (\(url)) was tapped!, ")
        }
        customControl.onTapButton = {
            print("button was tapped!")
        }
    }
    
    func setupView() {
        view.addSubview(customControl)
        
        customControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customControl.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    @objc func customControlTapped() {
        print("CustomControl was tapped!")
    }
}

class CustomControl: UIControl, UITextViewDelegate {
    private let stackView = UIStackView()
    private let label1 = UILabel()
    private let label2 = UILabel()
    private let button = UIButton(type: .system)
    private let textView = UITextView()
    
    var onTapButton: (() -> Void)?
    var onTapUrl: ((_ url: URL) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label1.text = "Label 1"
        label2.text = "Label 2"
        
        button.setTitle("Click me", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.addArrangedSubview(label1)
        stackView.addArrangedSubview(label2)
        stackView.addArrangedSubview(button)
        stackView.addArrangedSubview(textView)
        
        setupTextView()
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    func setupTextView() {
        let linkText = "OpenAI"
        let fullText = "Visit \(linkText), to test "
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.link, value: "https://www.openai.com", range: NSRange(location: 6, length: linkText.count))
        textView.attributedText = attributedString
        textView.isEditable = false
        textView.isUserInteractionEnabled = true
        textView.dataDetectorTypes = .link
        textView.backgroundColor = .lightGray
        textView.textColor = .blue
        textView.delegate = self
        textView.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 檢查button是否被點擊
        let buttonPoint = button.convert(point, from: self)
        if let hitButtonView = button.hitTest(buttonPoint, with: event) {
            return hitButtonView
        }

        // 檢查textView中的鏈接是否被點擊
        var textViewPoint = textView.convert(point, from: self)
        textViewPoint = CGPoint(x: textViewPoint.x - textView.textContainerInset.left + textView.contentOffset.x,
                                y: textViewPoint.y - textView.textContainerInset.top + textView.contentOffset.y)

        /*
         在iOS的文本渲染系統中，文本的每個可視元素都是一個“字形（glyph）”。每個字形代表一個或多個字符的視覺表示。例如，當一些語言的兩個字符組合時，它們可能會形成一個單獨的字形。所以，在視覺上呈現的每個元素和真實的字符之間可能存在不同。

         glyphIndex:

         代表當前文本中特定字形的索引。
         這是基於視覺表示，而不是實際的字符數量。
         layoutManager可以使用這個索引確定字形的確切位置和大小。
         characterIndex:

         代表實際字符在字符串中的位置。
         這是基於實際的字符數量。
         layoutManager可以將glyphIndex轉換為相應的characterIndex。
         當您點擊UITextView時，我們需要確定點擊位置的字形索引（glyphIndex），然後再找到該字形對應的字符索引（characterIndex）。一旦我們知道了字符索引，我們就可以檢查該位置的字符是否有特定的屬性（例如，一個鏈接）。
         */
        let layoutManager = textView.layoutManager
        let textContainer = textView.textContainer
        // 使用layoutManager的glyphIndex(for:in:fractionOfDistanceThroughGlyph:)方法來獲取點擊位置的glyphIndex。
        let glyphIndex = layoutManager.glyphIndex(for: textViewPoint, in: textContainer, fractionOfDistanceThroughGlyph: nil)
        // 使用layoutManager的characterIndexForGlyph(at:)方法將glyphIndex轉換為characterIndex。
        let characterIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)
        
        // 使用characterIndex來檢查點擊位置的字符是否具有鏈接屬性。
        if characterIndex < textView.attributedText.length {
            if textView.attributedText.attribute(.link, at: characterIndex, effectiveRange: nil) != nil {
                return textView
            }
        }

        // 若上述都不是點擊目標，但點擊仍在CustomControl上
        if bounds.contains(point) {
            return self
        }
        
        return nil
    }

    @objc func buttonTapped() {
        onTapButton?()
    }
    
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if textView === textView {
            onTapUrl?(URL)
        }
        return false
    }
}
