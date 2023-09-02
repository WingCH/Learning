//
//  CustomDragGesture.swift
//  study_button_group
//
//  Created by Wing on 2/9/2023.
//  ref: https://sarunw.com/posts/move-view-around-with-drag-gesture-in-swiftui/
//  ref: https://www.fatbobman.com/posts/swiftuiGesture/

import SwiftUI

public struct DragGestureViewModifier: ViewModifier {
    @Binding private var position: CGPoint
    @GestureState private var startPosition: CGPoint? = nil

    public init(position: Binding<CGPoint>) {
        self._position = position
    }

    public func body(content: Content) -> some View {
        content
            .highPriorityGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged { value in
                        var newPosition = startPosition ?? position
                        newPosition.x += value.translation.width
                        newPosition.y += value.translation.height
                        position = newPosition
                    }
                    .updating($startPosition) { _, startPosition, _ in
                        startPosition = startPosition ?? position
                    }
            )
    }
}

public extension View {
    func onDrag(position: Binding<CGPoint>) -> some View {
        modifier(DragGestureViewModifier(position: position))
    }
}
