//
//  VideoCell.swift
//  Kale
//
//  Created by Lyndon Samual McKay on 5/12/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import RealmSwift

class VideoCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var videoImageView: UIImageView!
    @IBOutlet var borderView: UIView!

    var video = Video()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        borderView.layer.cornerRadius = 3
//        borderView.layer.borderWidth = 1
//        borderView.layer.borderColor = UIColor.lightGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func get_video_image(url:String){
        // downloads article image
        var new_url = url
        
        print("downloads article image")
        print("using url: \(new_url)")
        let i_url = URL(string: new_url)
        videoImageView.kf.setImage(with: i_url)
        videoImageView.layer.cornerRadius = 3
    }
    

}
