//
//  KeyValueView.swift
//  keyValueView
//
//  Created by Wing CHAN on 13/4/2023.
//

import Foundation
import UIKit

/*
 If both keyLabel and valueLabel are relatively short, they can be displayed on the same line.
 +--------------------------------------------------+
 |    keyLabel(short) | valueLabel(short)           |
 +--------------------------------------------------+
 
 If the content of valueLabel is too long and cannot be displayed on the same line as keyLabel, the entire valueLabel will be displayed on the next line.
 +--------------------------------------------------+
 |    keyLabel(short)                               |
 |    valueLabel(long)                              |
 |--------------------------------------------------|
 
 */
public class KeyValueView: UIView {
    private let keyLabel: UILabel = .init()
    private let valueLabel: UILabel = .init()
    
    private var preferredMaxLayoutWidth: CGFloat = 0
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        keyLabel.numberOfLines = 0
        valueLabel.numberOfLines = 0
        addSubview(keyLabel)
        addSubview(valueLabel)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        // Set the preferred maximum layout width based on the view's frame width
        preferredMaxLayoutWidth = frame.width
        
        // Calculate the size of keyLabel and valueLabel when arranged in a single line
        let keyLabelSizeInLine = keyLabel.sizeThatFits(.zero)
        let valueLabelSizeInLine = valueLabel.sizeThatFits(.zero)
        
        // Check if keyLabel spans more than one line
        let isKeyLabelMoreThanOneLine: Bool = keyLabelSizeInLine.width > preferredMaxLayoutWidth
        
        // Set the frame of keyLabel
        if isKeyLabelMoreThanOneLine {
            let keyLabelSizeInMultiline = keyLabel.sizeThatFits(.init(width: preferredMaxLayoutWidth, height: 0))
            keyLabel.frame = CGRect(x: 0, y: 0, width: preferredMaxLayoutWidth, height: keyLabelSizeInMultiline.height)
        } else {
            keyLabel.frame = CGRect(x: 0, y: 0, width: keyLabelSizeInLine.width, height: keyLabelSizeInLine.height)
        }
        
        // Calculate the remaining width after placing keyLabel
        let remainingWidth = preferredMaxLayoutWidth - keyLabelSizeInLine.width

        // Set the frame of valueLabel
        if remainingWidth >= valueLabelSizeInLine.width, !isKeyLabelMoreThanOneLine {
            let newSize = valueLabel.sizeThatFits(.init(width: remainingWidth, height: 0))
            valueLabel.frame = CGRect(x: keyLabel.frame.width, y: 0, width: newSize.width, height: newSize.height)
        } else {
            let valueLabelSizeInMultiline = valueLabel.sizeThatFits(.init(width: preferredMaxLayoutWidth, height: 0))
            valueLabel.frame = CGRect(x: 0, y: keyLabel.frame.height, width: valueLabelSizeInMultiline.width, height: valueLabelSizeInMultiline.height)
        }
        
        // Invalidate the intrinsic content size after updating the frames
        invalidateIntrinsicContentSize()
    }
    
    override public var intrinsicContentSize: CGSize {
        // Calculate the intrinsic content size based on the preferred maximum layout width
        // and the height up to the maximum y-coordinate of the valueLabel frame
        let size = CGSize(width: preferredMaxLayoutWidth, height: valueLabel.frame.maxY)
        return size
    }
    
    public func config(key: String, value: String) {
        print(#function)
        keyLabel.text = key
        valueLabel.text = value
        
        // trigger `layoutSubviews`
        setNeedsLayout()
    }
}
