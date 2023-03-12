//
//  ViewController.swift
//  dynamic-height-RxDataSources
//
//  Created by Wing on 28/2/2023.
//

import RxDataSources
import RxSwift
import Then
import TinyConstraints
import UIKit

class CutomCell: UITableViewCell {
    let myView: UIView = .init()
    var sizeConstraints: Constraints?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.do {
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
        // 100 實際會變左 100.33 why???, 所以要加equalOrGreater
        sizeConstraints = [myView.height(size * 25, relation: .equalOrGreater)]
        myView.backgroundColor = randomColor()
    }

    func randomColor() -> UIColor {
        let red = CGFloat(arc4random_uniform(256)) / 255.0
        let green = CGFloat(arc4random_uniform(256)) / 255.0
        let blue = CGFloat(arc4random_uniform(256)) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

struct MySection {
    var header: String
    var items: [Item]
}

extension MySection: AnimatableSectionModelType {
    typealias Item = Int

    var identity: String {
        return header
    }

    init(original: MySection, items: [Item]) {
        self = original
        self.items = items
    
        
    }
}

class ViewController: UIViewController {
    private let tableView: UITableView = .init()
    private let disposeBag = DisposeBag()
    var dataSource: RxTableViewSectionedAnimatedDataSource<MySection>?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)

        tableView.edgesToSuperview()

        tableView.register(CutomCell.self, forCellReuseIdentifier: String(describing: CutomCell.self))
        dataSource = ViewController.dataSource()
        let sections = [
            MySection(
                header: "First section",
                items: Array(0 ... 5)
            )
        ]
        Observable.just(sections)
            .bind(to: tableView.rx.items(dataSource: dataSource!))
            .disposed(by: disposeBag)
    }
}

extension ViewController {
    static func dataSource() -> RxTableViewSectionedAnimatedDataSource<MySection> {
        return RxTableViewSectionedAnimatedDataSource<MySection>(
            configureCell: { _, table, _, item in
                guard let cell = table.dequeueReusableCell(withIdentifier: String(describing: CutomCell.self)) as? CutomCell else {
                    return UITableViewCell()
                }
                cell.configure(size: CGFloat(item))
                return cell
            },
            titleForHeaderInSection: { dataSource, index in
                dataSource.sectionModels[index].header
            }
        )
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
