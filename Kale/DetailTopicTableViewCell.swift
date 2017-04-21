//
//  DetailTopicTableViewCell.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 12/31/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit

class DetailTopicTableViewCell: UITableViewCell {

    @IBOutlet var topicImageView: UIImageView!
    
    @IBOutlet var topicLabel: UILabel!
    @IBOutlet var descLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func download_image(image_url: String){
        // KingFisher download
        let url = URL(string: image_url)
        //        let image = UIImage(named: "default_profile_icon")
        topicImageView.kf.setImage(with: url)//, placeholder: image)
    }
    
}
