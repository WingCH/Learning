//
//  RootViewController.swift
//  study_uikit_bottom_sheet_without_present
//
//  Created by Wing on 4/8/2023.
//

import UIKit

class YourViewController: UIViewController {
    var onDismiss: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("YourViewController viewDidLoad")

        view.backgroundColor = .lightGray

        let dismissButton = UIButton(type: .system)
        dismissButton.setTitle("Dismiss", for: .normal)
        dismissButton.addTarget(self, action: #selector(didTapDismissButton), for: .touchUpInside)

        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dismissButton)
        NSLayoutConstraint.activate([
            dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dismissButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc func didTapDismissButton() {
        onDismiss?()
    }
}

class BottomSheetViewController: UIViewController {
    private var bottomSheetView: BottomSheetView?
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .yellow
        setupButton()
    }

    private func setupButton() {
        let button = UIButton(type: .system)
        button.setTitle("Show Bottom Sheet", for: .normal)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)

        view.addSubview(button)
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        button.center = view.center
    }

    @objc private func didTapButton() {
        let vc = YourViewController()
        vc.onDismiss = { [weak self] in
            self?.bottomSheetView?.close(completion: {
                self?.bottomSheetView = nil
            })
        }
        bottomSheetView = BottomSheetView(contentViewController: vc)

        bottomSheetView?.show(in: view, height: 300)
    }
}
