//
//  RootViewController.swift
//  carousel
//
//  Created by Wing on 19/6/2022.
//

import UIKit

class RootViewController: UIViewController {
    // MARK: - Subvies

    private var carouselView: CarouselView?

    // MARK: - Properties

    private var carouselData: [CarouselView.CarouselData] = []
    private let backgroundColors: [UIColor] = [#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), #colorLiteral(red: 0.4826081395, green: 0.04436998069, blue: 0.2024421096, alpha: 1), #colorLiteral(red: 0.1728022993, green: 0.42700845, blue: 0.3964217603, alpha: 1)]

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        carouselView = CarouselView()
        carouselData.append(.init(color: .red, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"))
        carouselData.append(.init(color: .blue, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"))
        carouselData.append(.init(color: .yellow, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"))
        
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        carouselView?.configureView(with: carouselData)
    }
}

// MARK: - Setups

private extension RootViewController {
    func setupUI() {
        view.backgroundColor = backgroundColors.first

        guard let carouselView = carouselView else { return }
        view.addSubview(carouselView)
        carouselView.translatesAutoresizingMaskIntoConstraints = false
        carouselView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        carouselView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        carouselView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        carouselView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
