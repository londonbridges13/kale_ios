//
//  ProductCell.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 12/2/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit

class ProductCell: UITableViewCell {

    @IBOutlet var productLabel: UILabel!
    @IBOutlet var topicLabel: UILabel!
    @IBOutlet var productImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
