//
//  ViewController.swift
//  Dynamic height TableView in a Scroll View
//
//  Created by WingCH on 24/2/2021.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var tbl_view: UITableView!
    @IBOutlet var tbl_height: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_: Bool) {
        tbl_view.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        tbl_view.reloadData()
    }

    override func viewWillDisappear(_: Bool) {
        tbl_view.removeObserver(self, forKeyPath: "contentSize")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if object is UITableView {
                if let newValue = change?[.newKey] {
                    if let newSize = newValue as? CGSize {
                        tbl_height.constant = newSize.height
                    }
                }
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 20
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TestCell", for: indexPath) as? TestCell {
            cell.ibl_txt.text = "Test \(indexPath.row)"
            return cell
        }

        return UITableViewCell()
    }
}
