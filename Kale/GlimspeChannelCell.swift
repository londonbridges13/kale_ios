//
//  GlimspeChannelCell.swift
//  Kale
//
//  Created by Lyndon Samual McKay on 5/21/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Kingfisher
import Hero
import RealmSwift
import Alamofire

protocol GlimspeChannelCellDelegate {
    func add_one_to_channel_count()
    func subtract_one_to_channel_count()
}
class GlimspeChannelCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var titleLabel : UILabel!
//    @IBOutlet var subscriber_countLabel : UILabel!
//    @IBOutlet var subscribersLabel : UILabel!
    @IBOutlet var subscribeButton : UIButton!
    @IBOutlet var pictureImageView : UIImageView!
    @IBOutlet var collectionview : UICollectionView!

    var channel_id : Int?
    var fake_count : Int?
    var results = [Searchable]()
    var delegate : GlimspeChannelCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionview.dataSource = self
        collectionview.delegate = self
//        subscriber_countLabel.text = ""
        self.subscribeButton.addTarget(self, action: #selector(GlimspeChannelCell.pressed_subscribe_button), for: .touchUpInside)
        self.subscribeButton.layer.cornerRadius = 4
        pictureImageView.image = nil
        fake_count = titleLabel.text?.characters.count 
//        get_channel_info()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    
    
    
    // collection view
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GlimspeArticleCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GlimspeArticleCell", for: indexPath) as! GlimspeArticleCell
        
        if self.results[indexPath.row].article != nil{
            let url = URL(string: "\(self.results[indexPath.row].article!.article_image_url!)")
            cell.articleImageView.kf.setImage(with: url)
            if self.results[indexPath.row].article!.title != nil{
                cell.titleLabel.text = self.results[indexPath.row].article!.title!
            }
        } else if self.results[indexPath.row].video != nil{
            let url = URL(string: "\(self.results[indexPath.row].video!.video_image_url!)")
            cell.articleImageView.kf.setImage(with: url)
            if self.results[indexPath.row].video!.title != nil{
                cell.titleLabel.text = self.results[indexPath.row].video!.title!
            }
        }

        
        return cell
        
    }

    
    
    
    
    
    func get_channel_image(url:String){
        // downloads article image
        var new_url = url
        
        print("downloads article image")
        print("using url: \(new_url)")
        let i_url = URL(string: new_url)
        pictureImageView.kf.setImage(with: i_url)
        pictureImageView.layer.cornerRadius = 36
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
//                    self.subscriber_countLabel.text = "\(x)" // changed for amazon
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
                        if let delegate = self.delegate{
                            delegate.add_one_to_channel_count()
                        }
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
                        if let delegate = self.delegate{
                            delegate.subtract_one_to_channel_count()
                        }
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
    
    
    
    
    
    // Getting Channel's Content
    func get_channel_articles(){
        var pagination = 1
//        loaded_all_cells = false
        self.results.removeAll()
        
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "uchannel": channel_id!,
                "page": pagination
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/resources/glimpse_channel_content", method: .post, parameters: parameters).responseJSON { (response) in
                if let articles = response.result.value as? NSArray{
                    for each in articles{
                        if let article = each as? NSDictionary{
                            var resource_type = article["resource_type"] as? String
                            if resource_type != nil{
                                print("ResourceType : \(resource_type)")
                                if resource_type!.contains("video"){
                                    // It's an video
                                    print("Found a video")
                                    // Inside Video
                                    var v = Video()
                                    var id = article["id"] as? Int
                                    if id != nil{
                                        v.id = id!
                                    }
                                    var title = article["title"] as? String
                                    if title != nil{
                                        v.title = title!
                                    }
                                    var desc = article["desc"] as? String
                                    if desc != nil{
                                        v.desc = desc!
                                    }
                                    var article_image_url = article["article_image_url"] as? String
                                    if article_image_url != nil{
                                        v.video_image_url = "\(article_image_url!)"
                                    }
                                    var article_url = article["article_url"] as? String
                                    if article_url != nil{
                                        v.video_url = "\(article_url!)"
                                    }
                                    var display_topic = article["display_topic"] as? String
                                    if display_topic != nil{
                                        v.display_topic = "\(display_topic!)"
                                    }
                                    var article_date = article["article_date"] as? String
                                    if article_date != nil{
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                        let date = dateFormatter.date(from: article_date!)
                                        print("date: \(date)")
                                        v.video_date = date!
                                    }
                                    
                                    var result = Searchable()
//                                    self.videos.append(v)
                                    result.video = v
                                    self.results.append(result)
                                    
                                    
                                    //                            self.results.append(result)
                                    //                            print(v.desc)
                                    //                            print("\(self.results.count)")
//                                    self.get_article_resource(article: result)
                                    //                            self.tableview.reloadData()
                                }else{
                                    // It's an article
                                    // Inside Article
                                    var a = Article()
                                    var id = article["id"] as? Int
                                    if id != nil{
                                        a.id = id!
                                    }
                                    var title = article["title"] as? String
                                    if title != nil{
                                        a.title = title!
                                    }
                                    var desc = article["desc"] as? String
                                    if desc != nil{
                                        a.desc = desc!
                                    }
                                    var article_image_url = article["article_image_url"] as? String
                                    if article_image_url != nil{
                                        a.article_image_url = "\(article_image_url!)"
                                    }
                                    var article_url = article["article_url"] as? String
                                    if article_url != nil{
                                        a.article_url = "\(article_url!)"
                                    }
                                    var display_topic = article["display_topic"] as? String
                                    if display_topic != nil{
                                        a.display_topic = "\(display_topic!)"
                                    }
                                    var article_date = article["article_date"] as? String
                                    if article_date != nil{
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                        let date = dateFormatter.date(from: article_date!)
                                        print("date: \(date)")
                                        a.article_date = date!
                                    }
                                    
                                    var result = Searchable()
//                                    self.articles.append(a)
                                    result.article = a
                                    
                                    self.results.append(result)
                                    //                            print(a.desc)
                                    //                            print("\(self.results.count)")
//                                    self.get_article_resource(article: result)
                                    //                            self.tableview.reloadData()
                                }
                            }
                            self.collectionview.reloadData()
                            print("first results === \(self.results.count)")
                            
                        }
                    }
                }
            }
        }
    }
    


    
}
