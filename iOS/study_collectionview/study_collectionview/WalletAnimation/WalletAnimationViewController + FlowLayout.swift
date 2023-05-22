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
        private var itemAttributes: [UICollectionViewLayoutAttributes] = []
        private let overlapRatio: CGFloat = -(96 / 209)

        override func prepare() {
            guard let collectionView = collectionView else { return }

            itemAttributes = []
            let numberOfItems = collectionView.numberOfItems(inSection: 0)
            let collectionViewWidth = collectionView.bounds.width

            var yOffset: CGFloat = 0

            var _itemAttributes: [UICollectionViewLayoutAttributes] = []

            for item in 0 ..< numberOfItems {
                // The size and location of each item
                let indexPath = IndexPath(item: item, section: 0)
                let itemSizeWidth = collectionViewWidth - horizontalPadding * 2
                let itemSizeHeight = itemSizeWidth / CGFloat(itemRatio)
                let frame = CGRect(x: horizontalPadding, y: yOffset, width: itemSizeWidth, height: itemSizeHeight)

                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame

                // Overlap for each item
                let offsetY = attributes.frame.height * overlapRatio * CGFloat(attributes.indexPath.row)
                attributes.frame.origin.y += offsetY
                // Set the z-index of the item to its row number, so items in higher rows appear on top of items in lower rows
                attributes.zIndex = attributes.indexPath.row

                // bounce effect
                let stretchMultiplier: CGFloat = (1 + (CGFloat(item + 1) * -0.2))
                let contentOffsetTop = collectionView.contentOffset.y + collectionView.adjustedContentInset.top
                attributes.frame.origin.y = attributes.frame.origin.y + CGFloat(contentOffsetTop * stretchMultiplier)

                //
                
                yOffset += itemSizeHeight
                _itemAttributes.append(attributes)
            }

            itemAttributes = _itemAttributes
        }

        override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            return itemAttributes.filter { $0.frame.intersects(rect) }
        }

        override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            return itemAttributes[indexPath.item]
        }
        
        override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
            return true
        }

        override var collectionViewContentSize: CGSize {
            if let lastAttributes = itemAttributes.sorted(by: { $0.frame.maxY < $1.frame.maxY }).last {
                return CGSize(width: collectionView?.bounds.width ?? 0, height: lastAttributes.frame.maxY)
            }
            return .zero
        }
    }
}
