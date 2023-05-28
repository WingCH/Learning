//
//  WalletAnimationViewController.swift
//  study_collectionview
//
//  Created by Wing on 22/5/2023.
//

import UIKit

class WalletAnimationViewController: UIViewController {
    private let collectionViewLayout = CardsLayout()

    private var modelArray: [CustomCellModel] = []

    private lazy var collectionView: UICollectionView = .init(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        // Generate models
        for _ in 0 ..< 10 {
            let red = CGFloat(arc4random_uniform(256)) / 255.0
            let green = CGFloat(arc4random_uniform(256)) / 255.0
            let blue = CGFloat(arc4random_uniform(256)) / 255.0
            let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
            modelArray.append(CustomCellModel(color: color))
        }

        self.view.do {
            $0.addSubview(collectionView)
        }

        collectionView.do {
            $0.edgesToSuperview()
            $0.register(CustomCell.self, forCellWithReuseIdentifier: String(describing: CustomCell.self))
            $0.dataSource = self
            $0.delegate = self
        }
    }
}

extension WalletAnimationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modelArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CustomCell.self), for: indexPath) as! CustomCell
        cell.contentView.backgroundColor = modelArray[indexPath.row].color
        return cell
    }
}

extension WalletAnimationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionViewLayout.revealCardAt(index: indexPath.item)
    }
}

private class CustomCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct CustomCellModel {
    let color: UIColor

    init(color: UIColor) {
        self.color = color
    }
}
