//
//  GlimspeArticleCell.swift
//  Kale
//
//  Created by Lyndon Samual McKay on 5/21/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Kingfisher
import Hero
import RealmSwift

class GlimspeArticleCell: UICollectionViewCell {

    @IBOutlet var articleImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        
    }


}
