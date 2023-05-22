//
//  WalletAnimationViewController + FlowLayout.swift
//  study_collectionview
//
//  Created by Wing on 22/5/2023.
//

import UIKit

extension WalletAnimationViewController {
    class CardsLayout: UICollectionViewLayout {
        let itemRatio: Double = 335 / 209
        let horizontalPadding: Double = 20.0
        private var itemAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]

        override func prepare() {
            guard let collectionView = collectionView else { return }

            itemAttributes = [:]
            let numberOfItems = collectionView.numberOfItems(inSection: 0)
            let collectionViewWidth = collectionView.bounds.width

            var yOffset: CGFloat = 0

            for item in 0 ..< numberOfItems {
                let indexPath = IndexPath(item: item, section: 0)
                let itemSizeWidth = collectionViewWidth - horizontalPadding * 2
                let itemSizeHeight = itemSizeWidth / CGFloat(itemRatio)
                let frame = CGRect(x: horizontalPadding, y: yOffset, width: itemSizeWidth, height: itemSizeHeight)

                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame

                itemAttributes[indexPath] = attributes

                yOffset += itemSizeHeight
            }
        }

        override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            let visibleAttributes = itemAttributes.values.filter { $0.frame.intersects(rect) }
            return visibleAttributes
        }

        override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            return itemAttributes[indexPath]
        }

        override var collectionViewContentSize: CGSize {
            if let lastAttributes = itemAttributes.values.sorted(by: { $0.frame.maxY < $1.frame.maxY }).last {
                return CGSize(width: collectionView?.bounds.width ?? 0, height: lastAttributes.frame.maxY)
            }
            return .zero
        }
    }
}
