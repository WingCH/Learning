//
//  BottomSheetView.swift
//  study_uikit_bottom_sheet_without_present
//
//  Created by Wing on 4/8/2023.
//

import UIKit

protocol BottomSheetViewDismissable: UIViewController {
    var onDismiss: (() -> Void)? { get set }
}

class BottomSheetView<Content: BottomSheetViewDismissable>: UIView {
    private let contentViewController: Content

    init(contentViewController: Content) {
        self.contentViewController = contentViewController
        super.init(frame: .zero)
        contentViewController.onDismiss = { [weak self] in
            self?.hide()
        }
        setupView()
        setupGesture()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .systemBackground

        addSubview(contentViewController.view)
        contentViewController.view.frame = bounds
    }

    private func setupGesture() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(didDrag(_:)))
        addGestureRecognizer(gesture)
    }

    @objc private func didDrag(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        if translation.y >= 0 {
            transform = CGAffineTransform(translationX: 0, y: translation.y)
        }

        if gesture.state == .ended {
            if translation.y < 200 {
                UIView.animate(withDuration: 0.3) {
                    self.transform = .identity
                }
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
                }, completion: { _ in
                    self.hide()
                })
            }
        }
    }

    func show() {
        UIView.animate(withDuration: 0.3) {
            guard let superview = self.superview else { return }
            self.frame = CGRect(x: 0, y: superview.frame.height - self.frame.height, width: superview.frame.width, height: self.frame.height)
        }
    }

    func hide() {
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
            guard let superview = self.superview else { return }
            self.frame = CGRect(x: 0, y: superview.frame.height, width: superview.frame.width, height: self.frame.height)
        }
    }
}
