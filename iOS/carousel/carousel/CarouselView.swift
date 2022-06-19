//
//  CarouselView.swift
//  carousel
//
//  Created by Wing on 19/6/2022.
//  ref: https://medium.com/swlh/swift-carousel-759800aa2952

import UIKit

class CarouselView: UIView {
    struct CarouselData {
        let color: UIColor
        let text: String
    }

    // MARK: - Subviews

    private lazy var carouselCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.showsHorizontalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.dataSource = self
        collection.delegate = self
        collection.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.cellId)
        collection.backgroundColor = .clear
        return collection
    }()

//    private lazy var pageControl: UIPageControl = {
//        let pageControl = UIPageControl()
//        pageControl.pageIndicatorTintColor = .gray
//        pageControl.currentPageIndicatorTintColor = .white
//        return pageControl
//    }()

    // MARK: - Properties

    private var carouselData = [CarouselData]()
    private var currentPage = 0

    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setups

private extension CarouselView {
    func setupUI() {
        backgroundColor = .clear
        setupCollectionView()
    }

    func setupCollectionView() {
        addSubview(carouselCollectionView)
        carouselCollectionView.translatesAutoresizingMaskIntoConstraints = false
        carouselCollectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        carouselCollectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        carouselCollectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        carouselCollectionView.heightAnchor.constraint(equalToConstant: 450).isActive = true
    }
}

// MARK: - UICollectionViewDataSource

extension CarouselView: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return carouselData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCell.cellId, for: indexPath) as? CarouselCell else { return UICollectionViewCell() }

        let color = carouselData[indexPath.row].color
        let text = carouselData[indexPath.row].text

        cell.configure(color: color, text: text)

        return cell
    }
}

// MARK: - UICollectionView Delegate

extension CarouselView: UICollectionViewDelegate {
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        currentPage = getCurrentPage()
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        currentPage = getCurrentPage()
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        currentPage = getCurrentPage()
//    }
}

// MARK: - Public
extension CarouselView {
    public func configureView(with data: [CarouselData]) {
        let cellPadding = (frame.width - 300) / 2
        let carouselLayout = UICollectionViewFlowLayout()
        carouselLayout.scrollDirection = .horizontal
        carouselLayout.itemSize = .init(width: 300, height: 400)
        carouselLayout.sectionInset = .init(top: 0, left: cellPadding, bottom: 0, right: cellPadding)
        carouselLayout.minimumLineSpacing = cellPadding * 2
        carouselCollectionView.collectionViewLayout = carouselLayout

        carouselData = data
        carouselCollectionView.reloadData()
    }
}
