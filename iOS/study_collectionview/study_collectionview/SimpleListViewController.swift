//
//  SimpleListViewController.swift
//  study_collectionview
//
//  Created by Wing on 27/5/2023.
//

import UIKit

class SimpleListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    private var collectionView: UICollectionView!

    // 這是用於列表視圖的數據，你可以改成你自己需要的數據。
    private let dataArray = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "List View"
        view.backgroundColor = .systemBackground
        setupCollectionView()
    }

    private func setupCollectionView() {
        // 創建流覽佈局
        let layout = createCompositionalLayout()

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground

        // 註冊列表視圖的單元格 - 自定義或使用系統提供的單元格
        collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: "ListCell")

        view.addSubview(collectionView)
    }

    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { (_: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            // 創建單元格大小
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            // 創建組大小
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            // 創建節大小
            let section = NSCollectionLayoutSection(group: group)
//            section.contentInsets = NSDirectionalEdgeInsets(top: 100, leading: 0, bottom: 10, trailing: 0)

            return section
        }

        return layout
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: indexPath) as! UICollectionViewListCell

        var configuration = cell.defaultContentConfiguration()
        configuration.text = dataArray[indexPath.row]
        cell.contentConfiguration = configuration
        cell.accessories = [.disclosureIndicator()]

        return cell
    }
}
