//
//  ViewController.swift
//  dynamic-height-RxDataSources
//
//  Created by Wing on 28/2/2023.
//

import RxDataSources
import RxSwift
import TinyConstraints
import UIKit

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

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        dataSource = ViewController.dataSource()
        let sections = [
            MySection(header: "First section", items: [
                1,
                2
            ]),
            MySection(header: "Second section", items: [
                3,
                4
            ])
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
                let cell = table.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
                cell.textLabel?.text = "Item \(item)"

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
        // you can also fetch item
        guard let item = dataSource?[indexPath],
              // .. or section and customize what you like
              dataSource?[indexPath.section] != nil
        else {
            return 0.0
        }

        return CGFloat(40 + item * 10)
    }
}
