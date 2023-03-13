//
//  Animation1ViewController.swift
//  study_collectionview
//
//  Created by Wing on 13/3/2023.
//  https://stackoverflow.com/a/49844718/5588637

import UIKit

class Animation1ViewController: UIViewController {
    private let collectionViewLayout = LandingCarListViewLayout()

    private lazy var collectionView: UICollectionView = .init(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.do {
            $0.addSubview(collectionView)
        }

        collectionView.do {
            $0.edgesToSuperview()
            $0.register(CustomCell.self, forCellWithReuseIdentifier: String(describing: CustomCell.self))
            $0.dataSource = self
        }
    }
}

extension Animation1ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CustomCell.self), for: indexPath) as! CustomCell
        return cell
    }
}

private class CustomCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .green
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
