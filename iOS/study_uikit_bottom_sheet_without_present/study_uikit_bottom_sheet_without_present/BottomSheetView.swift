//
//  BottomSheetView.swift
//  study_uikit_bottom_sheet_without_present
//
//  Created by Wing on 4/8/2023.
//

import TinyConstraints
import UIKit

protocol BottomSheetViewDismissable: UIViewController {
    var onDismiss: (() -> Void)? { get set }
}

class BottomSheetView<Content: BottomSheetViewDismissable>: UIView {
    private let contentViewController: Content
    var onDismiss: (() -> Void)?

    private weak var parentView: UIView?
    private let contentView: UIView = UIView()

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
        backgroundColor = .clear
        addSubview(contentView)
        contentView.addSubview(contentViewController.view)
        contentViewController.view.edgesToSuperview()
    }

    private func setupGesture() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(didDrag(_:)))
        addGestureRecognizer(gesture)
    }

    @objc private func didDrag(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        print("gesture.state: \(gesture.state), translation.y: \(translation.y)")
        if translation.y >= 0 {
            contentView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        }

        if gesture.state == .ended {
            if translation.y < 200 {
                UIView.animate(withDuration: 0.3) {
                    self.contentView.transform = .identity
                }
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.contentView.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
                }, completion: { _ in
                    self.hide()
                })
            }
        }
    }

    func show(in parentView: UIView, height: CGFloat) {
        parentView.addSubview(self)
        self.contentView.transform = .identity
        self.parentView = parentView

        frame = parentView.bounds
        contentView.frame = CGRect(x: 0, y: parentView.frame.height - height, width: parentView.frame.width, height: height)
        contentView.transform = CGAffineTransform(translationX: 0, y: height)

        UIView.animate(withDuration: 0.3) {
            self.contentView.transform = .identity
            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }

    func hide() {
        UIView.animate(withDuration: 0.3, animations: {
            guard let parentView = self.parentView else { return }
            self.contentView.transform = CGAffineTransform(translationX: 0, y: parentView.frame.height)
            self.backgroundColor = UIColor.black.withAlphaComponent(0)
        }, completion: { _ in
            self.removeFromSuperview()
            self.onDismiss?()
        })
    }
}
