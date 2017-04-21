//
//  Topic_CollectionCell.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 12/1/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit

class Topic_CollectionCell: UICollectionViewCell {
    @IBOutlet var topicImageView: UIImageView!
    @IBOutlet var topicLabel: UILabel!
    @IBOutlet var board: UIView!

    override func awakeFromNib() {
        topicImageView.layer.cornerRadius = 3
        topicImageView.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        topicImageView.layer.cornerRadius = 3
        topicImageView.clipsToBounds = true
    }
    
    func download_image(image_url: String){
        // KingFisher download
        let url = URL(string: image_url)
        //        let image = UIImage(named: "default_profile_icon")
        topicImageView.kf.setImage(with: url)//, placeholder: image)
     
//        topicImageView.layer.masksToBounds = true
    }

}
