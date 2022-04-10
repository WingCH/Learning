//
//  TestCell.swift
//  Dynamic height TableView in a Scroll View
//
//  Created by WingCH on 24/2/2021.
//

import UIKit

class TestCell: UITableViewCell {

    @IBOutlet weak var ibl_txt: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
