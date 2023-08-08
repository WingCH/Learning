//
//  BottomSheetView.swift
//  study_uikit_bottom_sheet_without_present
//
//  Created by Wing on 4/8/2023.
//

import UIKit

public class BottomSheetView: UIView {
    private let contentViewController: UIViewController

    private weak var parentView: UIView?
    private let backgroundDimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0)
        return view
    }()

    public init(contentViewController: UIViewController) {
        self.contentViewController = contentViewController
        super.init(frame: .zero)
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
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentViewController.view.topAnchor.constraint(equalTo: topAnchor),
            contentViewController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentViewController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupGesture() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(didDrag(_:)))
        addGestureRecognizer(gesture)
    }

    @objc private func didDrag(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        print("gesture.state: \(gesture.state), translation.y: \(translation.y)")
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
                    self.close()
                })
            }
        }
    }

    public func show(in parentView: UIView, height: CGFloat) {
        parentView.addSubview(self)
        self.transform = .identity
        self.parentView = parentView
        parentView.addSubview(backgroundDimmedView)
        backgroundDimmedView.frame = parentView.bounds

        parentView.addSubview(self)
        frame = CGRect(x: 0, y: parentView.frame.height - height, width: parentView.frame.width, height: height)
        transform = CGAffineTransform(translationX: 0, y: height)

        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
            self.backgroundDimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }

    public func close(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            guard let parentView = self.parentView else { return }
            self.transform = CGAffineTransform(translationX: 0, y: parentView.frame.height)
            self.backgroundDimmedView.backgroundColor = UIColor.black.withAlphaComponent(0)
        }, completion: { _ in
            self.backgroundDimmedView.removeFromSuperview()
            self.removeFromSuperview()
            completion?()
        })
    }
}
