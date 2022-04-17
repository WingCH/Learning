//
//  TinyView.swift
//  TestingMasterTinyConstraints
//
//  Created by Alex Nagy on 20/05/2019.
//  Copyright © 2019 Alex Nagy. All rights reserved.
//

import UIKit

class TinyView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(backgroundColor: UIColor, cornerRadius: CGFloat = 6, borderWidth: CGFloat = 2) {
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = UIColor.white.cgColor
        layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
