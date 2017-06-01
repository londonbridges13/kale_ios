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
    var fake_count : Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subscriber_countLabel.text = ""
        post_countLabel.text = ""
        self.subscribeButton.addTarget(self, action: "pressed_subscribe_button", for: .touchUpInside)
        self.subscribeButton.layer.cornerRadius = 4
        pictureImageView.image = nil //UIImage(named: "profile_pic")
        get_channel_info()
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
    }

    func show_subscribe_button(){
        let color = UIColor(colorLiteralRed: 29/255, green: 171/255, blue: 184/255, alpha: 1)
        self.subscribeButton.setTitle("Subscribe", for: .normal)
        self.subscribeButton.layer.borderWidth = 0
        self.subscribeButton.setTitleColor(UIColor.white, for: .normal)
        self.subscribeButton.backgroundColor = color

    }
    
    func show_subscribed_button(){
//        let color = UIColor(colorLiteralRed: /255, green: /255, blue: /255, alpha: 1)
        self.subscribeButton.layer.borderWidth = 1
        self.subscribeButton.setTitle("Subscribed", for: .normal)
        self.subscribeButton.layer.borderColor = UIColor.gray.cgColor
        self.subscribeButton.setTitleColor(UIColor.gray, for: .normal)
        self.subscribeButton.backgroundColor = UIColor.white
        
    }
    
    // turn all below into one api request in update
    func count_posts(id: Int){
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "uchannel": id
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/resources/count_channel_posts", method: .post, parameters: parameters).responseJSON { (response) in
                if response.result.value != nil{
                    self.post_countLabel.text = "\(response.result.value!)" // changed for amazon
                    print("done")
                }
            }
        }
    }
    
    func count_subscribers(id: Int){
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "uchannel": id
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/resources/count_channel_followers", method: .post, parameters: parameters).responseJSON { (response) in
                if response.result.value != nil{
                    let result = response.result.value! as! Int
                    var x = (self.fake_count! * 2) + result
                    self.subscriber_countLabel.text = "\(x)" // changed for amazon
                    print("done")
                }
            }
        }

    }
    
    func is_subscribed(id: Int){
        // determine whether the user is subscribed to the channel
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!,
                "uchannel": id
            ]
            self.channel_id = id
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/resources/is_following_channel", method: .post, parameters: parameters).responseJSON { (response) in
                if response.result.value != nil{
                    // Change Button's Look (show_subscribe_button)
                    let result = response.result.value as! String
                    if result == "true"{
                        self.show_subscribed_button()
                    }else{
                        // false, show subscribe button
                        self.show_subscribe_button()
                    }
                    print("done")
                }
            }
        }

    }

    func get_description(id: Int){
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "uchannel": id
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/resources/channel_description", method: .post, parameters: parameters).responseJSON { (response) in
                if response.result.value != nil{
                    self.descriptionLabel.text = "\(response.result.value!)" // changed for amazon
                    print("done")
                }
            }
        }

    }
    
    
    func subscribe_to_channel(){
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil && channel_id != nil{
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!,
                "uchannel": self.channel_id!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/resources/follow_channel", method: .post, parameters: parameters).responseJSON { (response) in
                if response.result.value != nil{
                    let result = response.result.value as! String
                    if result.contains("Successfully"){
                        self.show_subscribed_button()
                        print("subscribed")
                    }
                }
            }
        }
    }
    
    func unsubscribe_to_channel(){
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil && channel_id != nil{
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!,
                "uchannel": self.channel_id!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/resources/unfollow_channel", method: .post, parameters: parameters).responseJSON { (response) in
                if response.result.value != nil{
                    let result = response.result.value as! String
                    if result.contains("Successfully"){
                        self.show_subscribe_button()
                        print("unsubscribed")
                    }
                }
            }
        }
        
    }

    func pressed_subscribe_button(){
        if subscribeButton.titleLabel!.text == "Subscribe"{
            print("Subscribing...")
            subscribe_to_channel()
        }else{
            print("Unsubscribing...")
            unsubscribe_to_channel()
        }
    }

    
}
