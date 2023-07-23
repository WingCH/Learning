//
//  SelectionBoxView.swift
//  study_swiftui_flowlayout
//
//  Created by Wing on 23/7/2023.
//

import SwiftUI

/// A view representing a selection rectangle in a given area.
///
/// It displays a dashed rectangle with the properties defined by `strokeStyle`.
/// If `selectionRect` is empty, the view will be empty.
struct SelectionBoxView: View {
    // The area of the selection rectangle.
    let selectionRect: CGRect

    // The stroke style of the selection rectangle.
    let strokeStyle: StrokeStyle

    /// Creates a new selection box view with the given selection rectangle and stroke style.
    ///
    /// - Parameters:
    ///   - selectionRect: The area of the selection rectangle. If this rectangle is empty, the view will also be empty.
    ///   - strokeStyle: The stroke style of the selection rectangle. The default value is a round line of 1 point thickness with a dash pattern of [5].
    init(selectionRect: CGRect, strokeStyle: StrokeStyle = StrokeStyle(
        lineWidth: 1,
        lineCap: .round,
        lineJoin: .round,
        dash: [5]
    )) {
        self.selectionRect = selectionRect
        self.strokeStyle = strokeStyle
    }

    var body: some View {
        // If the selection rectangle is not empty, draw the rectangle with the given stroke style.
        // Otherwise, the view is empty.
        Group {
            if !selectionRect.isEmpty {
                Path { path in
                    path.addRect(selectionRect)
                }
                .stroke(Color.red, style: strokeStyle)
            }
        }
    }
}
