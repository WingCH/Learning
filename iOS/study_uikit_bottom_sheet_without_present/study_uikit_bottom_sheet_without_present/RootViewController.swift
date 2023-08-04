//
//  RootViewController.swift
//  study_uikit_bottom_sheet_without_present
//
//  Created by Wing on 4/8/2023.
//

import UIKit

class BottomSheetViewController: UIViewController {
    private let bottomSheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()

    private let showBottomSheetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Bottom Sheet", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        setupBottomSheet()
        setupButton()
    }

    private func setupBottomSheet() {
        view.addSubview(bottomSheetView)
        bottomSheetView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 300)

        let gesture = UIPanGestureRecognizer(target: self, action: #selector(didDrag(_:)))
        bottomSheetView.addGestureRecognizer(gesture)
        print("Bottom sheet setup completed")
    }

    private func setupButton() {
        view.addSubview(showBottomSheetButton)
        showBottomSheetButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        showBottomSheetButton.center = view.center
        showBottomSheetButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        print("Button setup completed")
    }

    @objc private func didTapButton() {
        print("Button tapped")
        UIView.animate(withDuration: 0.3) {
            self.bottomSheetView.frame = CGRect(x: 0, y: self.view.frame.height - 300, width: self.view.frame.width, height: 300)
        }
        print("Bottom sheet show animation started")
    }

    @objc private func didDrag(_ gesture: UIPanGestureRecognizer) {
        print("Bottom sheet dragged")
        let translation = gesture.translation(in: bottomSheetView)
        if translation.y >= 0 {
            bottomSheetView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        }

        if gesture.state == .ended {
            if translation.y < 200 {
                UIView.animate(withDuration: 0.3) {
                    self.bottomSheetView.transform = .identity
                }
                print("Bottom sheet snap back animation started")
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.bottomSheetView.transform = CGAffineTransform(translationX: 0, y: self.bottomSheetView.frame.height)
                }, completion: { _ in
                    self.bottomSheetView.transform = .identity
                    self.bottomSheetView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 300)
                    print("Bottom sheet hide animation completed")
                })
                print("Bottom sheet hide animation started")
            }
        }
    }
}
