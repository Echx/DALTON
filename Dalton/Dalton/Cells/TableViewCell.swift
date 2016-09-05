//
//  TableViewCell.swift
//  Dalton
//
//  Created by Jinghan Wang on 6/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	class func identifier() -> String {
		return NSStringFromClass(self)
	}
	
	class func registerCellForTableView(tableView: UITableView, reuseIdentifier: String) {
		let nibName = NSStringFromClass(self).characters.split{$0 == "."}.map(String.init).last
		if nibName != nil {
			let nib = UINib(nibName: nibName!, bundle: NSBundle(forClass: self))
			tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
		} else {
			print("Cell Register failed")
		}
	}
}
