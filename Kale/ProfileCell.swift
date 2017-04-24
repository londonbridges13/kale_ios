//
//  ProfileCell.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 12/4/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Kingfisher
import NVActivityIndicatorView

class ProfileCell: UITableViewCell {

    @IBOutlet var profileImageView : UIImageView!
    @IBOutlet var profileBackView : UIView!
    @IBOutlet var backView: UIView!
    @IBOutlet var lowerView: UIView!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var topicsButton: UIButton!
    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var update_image_button : UIButton!
    var actIndi : NVActivityIndicatorView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.image = UIImage(named: "profile_pic")
//        topicsButton.alpha = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func download_image(image_url: String){
        // KingFisher download
        let url = URL(string: image_url)
//        let image = UIImage(named: "default_profile_icon")
        profileImageView.kf.setImage(with: url)//, placeholder: image)
    }

    func loading_image(){
        // display activity indicator
        var size : CGFloat = 37
        var xxp = (self.profileImageView?.frame.width)! / 2 - (size / 2)
        var hp = (self.profileImageView?.frame.height)! / 2 - (size / 2)
        let frame = CGRect(x: xxp, y: hp, width: size, height: size)
        
        self.actIndi = NVActivityIndicatorView(frame: frame, type: .lineScale, color: UIColor.white, padding: 3)
        self.actIndi?.startAnimating()
        self.actIndi?.alpha = 0
        self.profileImageView?.addSubview(self.actIndi!)
        self.actIndi?.fadeIn(duration: 0.2)

    }
    
    func end_loading(){
        self.actIndi?.fadeOut(duration: 0.2)
    }
    
}
