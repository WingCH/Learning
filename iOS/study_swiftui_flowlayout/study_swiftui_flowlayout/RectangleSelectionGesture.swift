//
//  RectangleSelectionGesture.swift
//  study_swiftui_flowlayout
//
//  Created by Wing on 23/7/2023.
//

import SwiftUI

struct RectangleSelectionGesture: Gesture {
    @Binding var tags: [TagModel]
    // The rectangle drawn by the gesture
    @Binding var selectionRect: CGRect
    // The indexes of tags that have been processed by the gesture
    @State var processedIndexes: Set<Int> = []

    // The rectangles representing the on-screen position and size of each tag
    let tagRects: [CGRect]
    // The original state of the tags, stored when the gesture begins
    @State var originalTags: [TagModel]?

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
        let origin = CGPoint(x: min(start.x, end.x), y: min(start.y, end.y))
        let size = CGSize(width: abs(start.x - end.x), height: abs(start.y - end.y))
        return CGRect(origin: origin, size: size)
    }

    private func processTagSelectionChange(gestureArea: CGRect, originalTags: [TagModel]) {
        for (index, rect) in tagRects.enumerated() {
            let originalTag = originalTags[index]
            let currentTag = tags[index]

            if rect.intersects(gestureArea) {
                tags[index] = currentTag.copyWith(isSelected: !originalTag.isSelected)
                processedIndexes.insert(index)
            } else if processedIndexes.contains(index) {
                tags[index] = currentTag.copyWith(isSelected: originalTag.isSelected)
            }
        }
    }

    private func saveOriginalTagsIfNeeded() {
        guard originalTags == nil else { return }
        originalTags = tags
    }

    private func handleGestureEnd() {
        processedIndexes.removeAll()
        originalTags = nil
    }
}
