//
//  HomeViewController.swift
//  study_show_vs_push
//
//  Created by Wing on 19/7/2023.
//

import UIKit

class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the background color and title
        self.view.backgroundColor = .white
        self.title = "Home"

        // Create a button
        let button = UIButton(type: .system)
        button.setTitle("Go to Detail", for: .normal)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)

        // Add the button to the view
        self.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }

    @objc func buttonPressed() {
        let detailViewController = DetailViewController()

        // Uncomment the method you want to use

        // push
//         self.navigationController?.pushViewController(detailViewController, animated: true)

        // show
         self.show(detailViewController, sender: self)
    }
}
