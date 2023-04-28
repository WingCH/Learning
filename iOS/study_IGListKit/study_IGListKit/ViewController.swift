//
//  ViewController.swift
//  study_IGListKit
//
//  Created by Wing on 28/4/2023.
//

import IGListKit
import TinyConstraints
import UIKit

class ViewController: UIViewController, ListAdapterDataSource {
    lazy var adapter: ListAdapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    let data: [CustomModel] = [
        CustomModel(title: "Item 1", detail: "This is item 1.", imageName: "imageName1"),
        CustomModel(title: "Item 2", detail: "This is item 2. This is item 2. This is item 2. This is item 2.", imageName: "imageName2"),
        CustomModel(title: "Item 3", detail: "This is item 3.", imageName: "imageName1"),
        CustomModel(title: "Item 4", detail: "This is item 4.", imageName: "imageName2"),
        CustomModel(title: "Item 5", detail: "This is item 5.", imageName: "imageName1"),
        CustomModel(title: "Item 6", detail: "This is item 6.", imageName: "imageName2"),
        CustomModel(title: "Item 7", detail: "This is item 7.", imageName: "imageName1"),
        CustomModel(title: "Item 8", detail: "This is item 8.", imageName: "imageName2"),
        CustomModel(title: "Item 9", detail: "This is item 9.", imageName: "imageName1"),
        CustomModel(title: "Item 10", detail: "This is item 10.", imageName: "imageName2"),
        CustomModel(title: "Item 11", detail: "This is item 11.", imageName: "imageName1"),
        CustomModel(title: "Item 12", detail: "This is item 12.", imageName: "imageName2"),
        CustomModel(title: "Item 13", detail: "This is item 13.", imageName: "imageName1"),
        CustomModel(title: "Item 14", detail: "This is item 14.", imageName: "imageName2"),
        CustomModel(title: "Item 15", detail: "This is item 15.", imageName: "imageName1"),
        CustomModel(title: "Item 16", detail: "This is item 16.", imageName: "imageName2"),
        CustomModel(title: "Item 17", detail: "This is item 17.", imageName: "imageName1"),
        CustomModel(title: "Item 18", detail: "This is item 18.", imageName: "imageName2"),
        CustomModel(title: "Item 19", detail: "This is item 19.", imageName: "imageName1"),
        CustomModel(title: "Item 20", detail: "This is item 20.", imageName: "imageName2")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.edgesToSuperview()
        collectionView.backgroundColor = .white

        adapter.collectionView = collectionView
        adapter.dataSource = self
    }

    // MARK: ListAdapterDataSource

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return CustomSectionController()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

class CustomModel: NSObject, ListDiffable {
    let title: String
    let detail: String
    let imageName: String

    init(title: String, detail: String, imageName: String) {
        self.title = title
        self.detail = detail
        self.imageName = imageName
        super.init()
    }

    func diffIdentifier() -> NSObjectProtocol {
        return title as NSString
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? CustomModel else { return false }
        return title == object.title && detail == object.detail && imageName == object.imageName
    }
}

class CustomSectionController: ListSectionController {
    private var viewModel: CustomModel?

    override func sizeForItem(at index: Int) -> CGSize {
        guard let context = collectionContext,
              let viewModel = viewModel
        else {
            return CGSize()
        }
        let cell = CustomCell()
        cell.bindViewModel(viewModel)
        let size = cell.contentView.systemLayoutSizeFitting(
            CGSize(width: context.containerSize.width, height: .greatestFiniteMagnitude),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return CGSize(width: context.containerSize.width, height: size.height)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: CustomCell.self, for: self, at: index) as? CustomCell,
              let viewModel = viewModel
        else {
            return CustomCell()
        }
        cell.bindViewModel(viewModel)
        return cell
    }

    override func didUpdate(to object: Any) {
        viewModel = object as? CustomModel
    }
}

class CustomCell: UICollectionViewCell {
    let titleLabel = UILabel()
    let detailLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        detailLabel.font = UIFont.systemFont(ofSize: 14)
        detailLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        contentView.addSubview(textStack)
        textStack.edgesToSuperview(insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
    }

    func bindViewModel(_ viewModel: CustomModel) {
        titleLabel.text = viewModel.title
        detailLabel.text = viewModel.detail
    }
}
