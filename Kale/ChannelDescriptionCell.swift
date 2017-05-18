//
//  ChannelDescriptionCell.swift
//  Kale
//
//  Created by Lyndon Samual McKay on 5/17/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

class ChannelDescriptionCell: UITableViewCell {

//    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var descriptionLabel : UILabel!
    @IBOutlet var post_countLabel : UILabel!
    @IBOutlet var postsLabel : UILabel!
    @IBOutlet var subscriber_countLabel : UILabel!
    @IBOutlet var subscribersLabel : UILabel!
    @IBOutlet var subscribeButton : UIButton!
    @IBOutlet var pictureImageView : UIImageView!
    var channel_id : Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.subscribeButton.layer.cornerRadius = 4
        pictureImageView.image = nil //UIImage(named: "profile_pic")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func get_channel_image(url:String){
        // downloads article image
        var new_url = url
        
        print("downloads article image")
        print("using url: \(new_url)")
        let i_url = URL(string: new_url)
        pictureImageView.kf.setImage(with: i_url)
        pictureImageView.layer.cornerRadius = 40
    }
    
    func get_channel_info(){
        // run all functions
        self.count_posts()
    }

    func show_subcribe_button(){
        let color = UIColor(colorLiteralRed: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        self.subscribeButton.layer.borderWidth = 0
        self.subscribeButton.setTitleColor(UIColor.white, for: .normal)
        self.subscribeButton.backgroundColor = color

    }
    
    func show_subscribed_button(){
//        let color = UIColor(colorLiteralRed: /255, green: /255, blue: /255, alpha: 1)
        self.subscribeButton.layer.borderWidth = 1
        self.subscribeButton.layer.borderColor = UIColor.gray.cgColor
        self.subscribeButton.setTitleColor(UIColor.gray, for: .normal)
        self.subscribeButton.backgroundColor = UIColor.white
        
    }
    
    // turn all below into one api request in update
    func count_posts(){
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "uchannel": self.channel_id!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/resources/profile_pic", method: .post, parameters: parameters).responseJSON { (response) in
                if response.result.value != nil{
                    self.post_countLabel.text = "\(response.result.value!)" // changed for amazon
                    print("done")
                }
            }
        }
    }
    
    func count_subscribers(){
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "uchannel": self.channel_id!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/resources/profile_pic", method: .post, parameters: parameters).responseJSON { (response) in
                if response.result.value != nil{
                    self.subscriber_countLabel.text = "\(response.result.value!)" // changed for amazon
                    print("done")
                }
            }
        }

    }
    
    func is_subscribed(){
        // determine whether the user is subscribed to the channel
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!,
                "uchannel": self.channel_id!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/resources/profile_pic", method: .post, parameters: parameters).responseJSON { (response) in
                if response.result.value != nil{
                    // Change Button's Look (show_subscribe_button)
//                    self.post_countLabel.text = "\(response.result.value!)" // changed for amazon
                    print("done")
                }
            }
        }

    }

    func get_description(){
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "uchannel": self.channel_id!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/resources/profile_pic", method: .post, parameters: parameters).responseJSON { (response) in
                if response.result.value != nil{
                    self.descriptionLabel.text = "\(response.result.value!)" // changed for amazon
                    print("done")
                }
            }
        }

    }
}
