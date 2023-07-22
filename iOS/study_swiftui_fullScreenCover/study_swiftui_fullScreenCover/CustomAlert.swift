//
//  CustomAlert.swift
//  study_swiftui_fullScreenCover
//
//  Created by Wing CHAN on 20/7/2023.
//

import SwiftUI

struct CustomAlert<Content: View>: View {
    @Binding var isPresented: Bool
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            content
                .environment(
                    \.customAlertDismiss,
                    CustomAlertDismiss {
                        isPresented = false
                    }
                )
        }
    }
}

extension View {
    func customAlert<Content>(
        isPresented: Binding<Bool>,
        content: @escaping () -> Content
    ) -> some View where Content: View {
        ZStack {
            self
            ZStack { // for correct work of transition animation
                if isPresented.wrappedValue {
                    CustomAlert(isPresented: isPresented, content: content)
                        .transition(.opacity)
                }
            }
        }
    }
}

struct CustomAlertDismiss {
    private var action: () -> Void
    func dismiss() {
        action()
    }

    init(action: @escaping () -> Void = {}) {
        self.action = action
    }
}

struct CustomAlertDismissKey: EnvironmentKey {
    static var defaultValue: CustomAlertDismiss = CustomAlertDismiss()
}

extension EnvironmentValues {
    var customAlertDismiss: CustomAlertDismiss {
        get { self[CustomAlertDismissKey.self] }
        set { self[CustomAlertDismissKey.self] = newValue }
    }
}
