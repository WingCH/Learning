//
//  CarouselCell.swift
//  carousel
//
//  Created by Wing on 19/6/2022.
//

import UIKit

class CarouselCell: UICollectionViewCell {
    
    // MARK: - SubViews
    
    private lazy var colorView = UIView()
    private lazy var textLabel = UILabel()
    
    // MARK: - Properties
    
    static let cellId = "CarouselCell"
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}

// MARK: - Setups

private extension CarouselCell {
    func setupUI() {
        backgroundColor = .clear
        
        addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        colorView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        colorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        colorView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        colorView.contentMode = .scaleAspectFill
        colorView.clipsToBounds = true
        colorView.layer.cornerRadius = 24
        
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 16).isActive = true
        textLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        textLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.font = .systemFont(ofSize: 18)
        textLabel.textColor = .white
    }
}

// MARK: - Public

extension CarouselCell {
    public func configure(color: UIColor, text: String) {
        colorView.backgroundColor = color
        textLabel.text = text
    }
}
