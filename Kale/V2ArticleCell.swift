//
//  V2ArticleCell.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 4/1/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//


import UIKit
import Kingfisher
import Alamofire
import RealmSwift
//import FaveButton

protocol ArtcleCellDelegate{
    func update_article_cell(article : Article)
}

class V2ArticleCell: UITableViewCell {
    
//    @IBOutlet var topicLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var bloggerLabel: UILabel!
    @IBOutlet var articleImageView: UIImageView!
    @IBOutlet var bloggerImageView: UIImageView!
    @IBOutlet var shareButton: UIButton! // new v2
    @IBOutlet var likeButton: UIButton! // new v2
    @IBOutlet var likeCountLabel: UILabel!

    var done = false // make sure the cell doesn't load twice
    var l_article: Article?
    
    
    //update values
    var delegate : ArtcleCellDelegate?
    var user_like : Bool?
    var likes : Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        likeButton.addTarget(self, action: #selector(V2ArticleCell.like_article), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(V2ArticleCell.change_button), for: .touchUpInside)
        

        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func get_article_image(url:String){
        // downloads article image
        var new_url = url
  
        print("downloads article image")
        print("using url: \(new_url)")
        let i_url = URL(string: new_url)
        articleImageView.kf.setImage(with: i_url)
        articleImageView.layer.cornerRadius = 4
    }
    
    
    func get_blogger_image(url:String){
        // downloads article image
        var new_url = url

        print("downloads article image")
        print("using url: \(new_url)")
        let i_url = URL(string: new_url)
        bloggerImageView.kf.setImage(with: i_url)
        bloggerImageView.layer.cornerRadius = 26
    }
    
    
    
    
    
    //Delegate 
    func update_article(){
        if let delegate = delegate{
            delegate.update_article_cell(article: l_article!)
        }else{
            print("Can't Delegate")
        }
    }
    
    
    
    
    // Likes Features
    

    
    func change_button(){
        if l_article != nil{
            if self.l_article!.user_like == false {
                // change back to red heart icon
                self.l_article!.user_like = true
                self.like_animation()
//                likeButton.setImage(UIImage(named: "red heart icon"), for: .normal)
            }else{
                self.l_article!.user_like = false
                self.unlike_animation()
//                likeButton.setImage(UIImage(named: "selected heart icon"), for: .normal)
            }
        }
    }
    
    func like_animation(){
        
        UIView.animate(withDuration: 0.15) {
            self.likeButton.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        }
        var delayInSeconds = 0.15
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            UIView.animate(withDuration: 0.15) {
                self.likeButton.setImage(UIImage(named: "selected heart icon"), for: .normal)
                self.likeButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }

    func unlike_animation(){
        
        UIView.animate(withDuration: 0.15) {
            self.likeButton.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        }
        var delayInSeconds = 0.15
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            UIView.animate(withDuration: 0.15) {
                self.likeButton.setImage(UIImage(named: "red heart icon"), for: .normal)
                self.likeButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }

    
    func like_article(){
        // what happens when like button is tapped.
        // do animation, like instagram
        // send api request to save article and like it
        
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!,
                "uarticle" : l_article!.id!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/articles/like_an_article", method: .post, parameters: parameters).responseJSON { (response) in
                if let count = response.result.value as? Int{
                    self.l_article!.likes = count
                    self.update_article()
                    if count != 0{
                        self.likeCountLabel.text = " \(count)"
                    }else{
                        self.likeCountLabel.text = ""
                    }
                    print(response.result.value)
                }
            }
        }
        
    }

    
    // delete if launch works successfully
    
//    func get_article_likes(){
//        
//        let realm = try! Realm()
//        var user = realm.objects(User).first
//        if user != nil && user?.access_token != nil && user?.client_token != nil{
//            let parameters: Parameters = [
//                "access_token": user!.client_token!,
//                "uarticle" : l_article!.id!
//            ]
//            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/articles/get_article_like_count", method: .post, parameters: parameters).responseJSON { (response) in
//                if let count = response.result.value as? Int{
//                    self.likes = count
//                    self.l_article!.likes = count
//                    self.update_article() // update article in array on homevc
//                    if count != 0{
//                        self.likeCountLabel.text = " \(count)"
//                    }
//                    print(response.result.value)
//                }
//            }
//        }
//        
//    }
//    
//    func did_user_like_article(){
//        print("starting did_user_like_article")
//        let realm = try! Realm()
//        var user = realm.objects(User).first
//        if user != nil && user?.access_token != nil && user?.client_token != nil{
//            let parameters: Parameters = [
//                "access_token": user!.client_token!,
//                "utoken": user!.access_token!,
//                "uarticle" : l_article!.id!
//            ]
//            if self.done == false{
//                self.get_article_likes()
//                Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/users/did_user_like_article", method: .post, parameters: parameters).responseJSON { (response) in
//                    print("Result: \(response.result.value)")
//                    if let result = response.result.value as? Bool{
//                        self.user_like = result
//                        self.l_article!.user_like = result
//                        self.done = true
//                        if result == true{
//                            print("true, button state is now selected")
//                            // user already liked this. Set button as selected
//                            self.likeButton.isSelected = true
//                            
//                        }else{
//                            print("false or nothing")
//                            // user didn't like article, or error
//                            //do nothing
//                        }
//                        print("done did_user_like_article")
//                    }
//                }
//            }
//        }
//        
//    }
//    


  

}

