//
//  Animation1ViewController + FlowLayout1.swift
//  study_collectionview
//
//  Created by Wing on 13/3/2023.
//

import Foundation
import UIKit

extension Animation1ViewController {
    class LandingCarListViewLayout: UICollectionViewLayout {
        private static let carSize: CGSize = CGSize(width: 156, height: 293)
        private static let radius: CGFloat = 415.6
        private static let radianPerCar: CGFloat = 0.45379 // 26 degrees
        static let supplementaryViewKindCarInfo = "info"
        private var carAttributes: [UICollectionViewLayoutAttributes] = []
        private var carInfoAttributes: [UICollectionViewLayoutAttributes] = []
            
        override func prepare() {
            super.prepare()
             
            carAttributes = []
            carInfoAttributes = []
            
            guard let cv = collectionView else { return }
            
            let willScrollToLastItem: Bool = (cv.bounds.minX >= collectionViewContentSize.width)
            // Fix the glitch which switching layout from multiple items to single item when focusing second item, the item will receive incorrect layout
            // Thus when knowing the collection view is about to shrink, pre-calculate the layout for the shrinked look
            let offsetX: CGFloat = (willScrollToLastItem ? CGFloat(max(0, cv.numberOfItems(inSection: 0) - 1)) * cv.frame.width : cv.bounds.minX)
            let currentPage: CGFloat = offsetX / cv.frame.width
            let startingAngle: CGFloat = currentPage * Self.radianPerCar
            let infoViewYOffset: CGFloat = Self.carSize.height / 2 + 14
            let infoViewHeight: CGFloat = cv.frame.height - infoViewYOffset

            // Think of a disk rotating clockwise, and the angle is measuring from down in clockwise direction.
            // content offset x = 0, angle = 0 degrees. content offset x = frame.width / 2, angle = 20 degrees.
            for i in 0 ..< cv.numberOfItems(inSection: 0) {
                // For cell
                let attr = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: 0))
                let angle: CGFloat = startingAngle - CGFloat(i) * Self.radianPerCar
                // Align the item to the center x of the collection view
                let x: CGFloat = offsetX + cv.frame.width / 2 - Self.carSize.width / 2 - Self.radius * sin(angle)
                let y: CGFloat = -Self.carSize.height / 2 - Self.radius * (1 - cos(angle))
                attr.frame = CGRect(origin: CGPoint(x: x, y: y), size: Self.carSize)
                // Hide the invisible cell
                attr.alpha = max(1 - abs(currentPage - CGFloat(i)) * 0.8, 0)
                attr.isHidden = (attr.alpha == 0)
                carAttributes.append(attr)
                
                // For info view
                let infoViewAttr = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: Self.supplementaryViewKindCarInfo, with: IndexPath(item: i, section: 0))
                let infoViewXOffset: CGFloat = CGFloat(i) * cv.frame.width
                infoViewAttr.frame = CGRect(origin: CGPoint(x: infoViewXOffset, y: infoViewYOffset), size: CGSize(width: cv.frame.width, height: infoViewHeight))
                carInfoAttributes.append(infoViewAttr)
            }
        }

        override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            return carAttributes + carInfoAttributes
        }
        
        override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            return carAttributes[indexPath.item]
        }
        
        override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            return carInfoAttributes[indexPath.item]
        }
        
        override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
            return true
        }

        override var collectionViewContentSize: CGSize {
            if let cv = collectionView {
                return CGSize(width: CGFloat(cv.numberOfItems(inSection: 0)) * cv.frame.width, height: cv.frame.height)
            } else {
                return .zero
            }
        }
    }
}
