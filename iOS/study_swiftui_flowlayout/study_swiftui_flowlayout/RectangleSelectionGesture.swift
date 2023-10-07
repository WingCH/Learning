//
//  RectangleSelectionGesture.swift
//  study_swiftui_flowlayout
//
//  Created by Wing on 23/7/2023.
//

import SwiftUI

struct RectangleSelectionGesture: Gesture {
    @Binding var tags: [TagModel] // The current tags data models list
    @Binding var selectionRect: CGRect // The rectangle drawn by the gesture
    let tagRects: [CGRect] // The rectangles representing the on-screen position and size of each tag
    @State var originalTags: [TagModel]? // The original state of the tags, stored when the gesture begins

    var body: some Gesture {
        DragGesture()
            .onChanged { value in
                handleGestureChange(value: value)
            }
            .onEnded { _ in
                handleGestureEnd()
            }
    }

    private func handleGestureChange(value: DragGesture.Value) {
        saveOriginalTagsIfNeeded()
        guard let originalTags = originalTags else { return }

        let gestureArea = calculateGestureArea(start: value.startLocation, end: value.location)
        selectionRect = gestureArea

        processTagSelectionChange(gestureArea: gestureArea, originalTags: originalTags)
    }

    private func calculateGestureArea(start: CGPoint, end: CGPoint) -> CGRect {
        // Calculate the selection area from start point to end point
        let origin = CGPoint(x: min(start.x, end.x), y: min(start.y, end.y))
        let size = CGSize(width: abs(start.x - end.x), height: abs(start.y - end.y))
        return CGRect(origin: origin, size: size)
    }

    private func processTagSelectionChange(gestureArea: CGRect, originalTags: [TagModel]) {
        // Update the selection state of tags based on the gesture area and the original tag state
        for (index, rect) in tagRects.enumerated() {
            let originalTag = originalTags[index]
            let currentTag = tags[index]

            if rect.intersects(gestureArea) {
                tags[index] = currentTag.copyWith(isSelected: !originalTag.isSelected)
            } else if originalTag.isSelected != currentTag.isSelected {
                tags[index] = currentTag.copyWith(isSelected: originalTag.isSelected)
            }
        }
    }

    private func saveOriginalTagsIfNeeded() {
        // Save the current tag state if original tags are nil
        guard originalTags == nil else { return }
        originalTags = tags
    }

    private func handleGestureEnd() {
        // Reset the original tag state when the gesture ends
        originalTags = nil
    }
}
