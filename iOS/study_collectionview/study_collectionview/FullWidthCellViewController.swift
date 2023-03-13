//
//  FullWidthCellViewController.swift
//  study_collectionview
//
//  Created by Wing on 10/3/2023.
//
// This code shows how to use UICollectionView to make a user interface similar to that of UITableView.

import Then
import TinyConstraints
import UIKit

private class CustomCell: UICollectionViewCell {
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        /*
         CGFloat.greatestFiniteMagnitude表示可用於表示任何非無窮大浮點數的最大值。
         因此，如果您將視圖的高度設置為 CGFloat.greatestFiniteMagnitude
         那麼視圖的高度將不會受到任何限制，它可以是任何非無窮大浮點數的值。
         這在自適應佈局中非常有用，因為它可以讓系統計算出自適應視圖的最小可能大小，以適應其內容
         */
        var targetSize = targetSize
        targetSize.height = CGFloat.greatestFiniteMagnitude

        let size = super.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        return size
    }

    override func draw(_ rect: CGRect) {
        print(#function)
        super.draw(rect)
    }

    let myView: UIView = .init()
    var sizeConstraints: Constraints?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.do {
            $0.addSubview(myView)
        }

        myView.do {
            $0.edgesToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(size: CGFloat) {
        sizeConstraints?.deActivate()
        sizeConstraints = nil

        sizeConstraints = [myView.height(size * 25, priority: .fittingSizeLevel)]
        myView.backgroundColor = randomColor()
    }

    func randomColor() -> UIColor {
        let red = CGFloat(arc4random_uniform(256)) / 255.0
        let green = CGFloat(arc4random_uniform(256)) / 255.0
        let blue = CGFloat(arc4random_uniform(256)) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

class FullWidthCellViewController: UIViewController {
    private let collectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return layout
    }()

    private lazy var collectionView: UICollectionView = .init(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    )

    let dataArray: [Double] = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.do {
            $0.addSubview(collectionView)
            $0.backgroundColor = .red
        }

        collectionView.do {
            $0.edgesToSuperview()
            $0.register(CustomCell.self, forCellWithReuseIdentifier: String(describing: CustomCell.self))
            $0.delegate = self
            $0.dataSource = self
        }
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout = collectionView.collectionViewLayout
        if let flowLayout = layout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(
                width: collectionView.bounds.width,
                height: 10
            )
            // remove spacing between each cell
//            flowLayout.minimumLineSpacing = 0
//            flowLayout.minimumInteritemSpacing = 0
        }
    }
}

extension FullWidthCellViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CustomCell.self), for: indexPath) as! CustomCell
        cell.configure(size: dataArray[indexPath.row])
        return cell
    }
}

extension FullWidthCellViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt: \(indexPath)")
    }
}
