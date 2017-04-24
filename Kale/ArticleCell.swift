//
//  ArticleCell.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 12/2/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Kingfisher

class ArticleCell: UITableViewCell {

    @IBOutlet var topicLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var resourceLabel: UILabel!
    @IBOutlet var articleImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func get_article_image(url:String){
        // downloads article image
        var new_url = url
//        if url.contains("https") == false{
//            if url.contains("http") == false{
//                new_url = "https://\(url)"
//            }else{
                // contains http before url, remove http add an https
//                let replaced = (url as NSString).replacingOccurrences(of: "http", with: "https")
//                new_url = replaced
//            }
//        }
        print("downloads article image")
        print("using url: \(new_url)")
        let i_url = URL(string: new_url)
        articleImageView.kf.setImage(with: i_url)
    }
    
}

