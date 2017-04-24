//
//  OnboardResourceTableViewCell.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 11/30/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit

class OnboardResourceTableViewCell: UITableViewCell {

    
    @IBOutlet var resourceLabel: UILabel!
    @IBOutlet var resourceImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
