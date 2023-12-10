//
//  AnchoredPosition.swift
//  AnchoredPosition
//
//  Created by Matthaus Woolard on 2/05/23.
//  https://nilcoalescing.com/blog/AnchoredPositionInSwiftUI/

import SwiftUI

struct AnchoredPosition: Layout {
    let location: CGPoint
    let anchor: UnitPoint
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        return proposal.replacingUnspecifiedDimensions()
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let locationInBounds = CGPoint(
            x: location.x + bounds.origin.x,
            y: location.y + bounds.origin.y
        )
        
        for view in subviews {
            if let alternativeAnchor = alternativeAnchor(for: view, in: bounds) {
                view.place(
                    at: locationInBounds,
                    anchor: alternativeAnchor,
                    proposal: remainingProposedSize(in: bounds, for: alternativeAnchor)
                )
            } else {
                view.place(
                    at: locationInBounds,
                    anchor: anchor,
                    proposal: remainingProposedSize(in: bounds, for: anchor)
                )
            }
        }
    }
    
    func alternativeAnchor(for view: LayoutSubview, in bounds: CGRect) -> UnitPoint? {
        let viewSize = view.sizeThatFits(remainingProposedSize(in: bounds, for: self.anchor))
        switch anchor {
        case .center, .zero:
            return nil
        case .top:
            if viewSize.height + location.y > bounds.height {
                return .bottom
            }
        case .bottom:
            if viewSize.height > location.y {
                return .top
            }
        case .bottomLeading:
            if viewSize.width + location.x > bounds.width {
                return .bottomTrailing
            }
        case .bottomTrailing:
            if viewSize.width > location.x {
                return .bottomLeading
            }
        case .topLeading:
            if viewSize.width + location.x > bounds.width {
                return .topTrailing
            }
        case .topTrailing:
            if viewSize.width > location.x {
                return .topLeading
            }
        case .leading:
            if viewSize.width + location.x > bounds.width {
                return .trailing
            }
        case .trailing:
            if viewSize.width > location.x {
                return .leading
            }
        default:
            return nil
        }
        return nil
    }
 
    func remainingProposedSize(
        in bounds: CGRect,
        for anchor: UnitPoint
    ) -> ProposedViewSize {
        var newProposal = ProposedViewSize(width: bounds.width, height: bounds.height)
        
        let leadingWidth = bounds.width - location.x
        let topHeight = bounds.height - location.y
        
        switch anchor {
        case .bottom:
            newProposal.height = location.y
        case .bottomLeading:
            newProposal.height = location.y
            newProposal.width = leadingWidth
        case .bottomTrailing:
            newProposal.height = location.y
            newProposal.width = location.x
        case .center, .zero:
            break
        case .leading:
            newProposal.width = leadingWidth
        case .top:
            newProposal.height = topHeight
        case .topLeading:
            newProposal.height = topHeight
            newProposal.width = leadingWidth
        case .topTrailing:
            newProposal.height = topHeight
            newProposal.width = location.x
        case .trailing:
            newProposal.width = location.y
        default:
            break
        }
        return newProposal
    }
}
