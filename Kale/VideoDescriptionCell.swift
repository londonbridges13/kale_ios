//
//  VideoDescriptionCell.swift
//  Kale
//
//  Created by Lyndon Samual McKay on 5/13/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import Kingfisher

class VideoDescriptionCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var resourceLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var resourceImageView: UIImageView!
    @IBOutlet var shareButton: UIButton! // set the action in vvc
    @IBOutlet var channelButton: UIButton! // button to visit channel

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func get_blogger_image(url:String){
        // downloads article image
        var new_url = url
        
        print("downloads article image")
        print("using url: \(new_url)")
        let i_url = URL(string: new_url)
        resourceImageView.kf.setImage(with: i_url)
        resourceImageView.layer.cornerRadius = 26
    }

    
    func get_article_resource(article : Searchable){
        print("starting get_article_resource ...")
        // sets the resource for the article, for user to know where article came from
        //        self.loaded_all_cells = true
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            var id : Int?
            if article.article != nil{
                id = article.article!.id!
            }else if article.video != nil{
                id = article.video!.id!
            }
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "uarticle": id!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/resources/get_resource", method: .post, parameters: parameters).responseJSON { (response) in
                //                print(response.result.value!)
                if response.result.value != nil{
                    
                    if let resource = response.result.value as? NSDictionary{
                        // Inside Resource
                        var r = Resource()
                        var title = resource["title"] as? String?
                        if title != nil{
                            r.blogger = title!
                        }
                        
                        var image_url = resource["article_image_url"] as? String // using article model to display resource and url in same query
                        if image_url != nil{
                            r.blogger_image_url = image_url!
                            print("Hey blogger url: \(image_url!)")
                        }
                        
                        var id = resource["id"] as? Int
                        if id != nil{
                            r.id = id!
                        }
                        
                        article.article?.resource = r // already grabs image url
                        article.video?.resource = r // already grabs image url
                        
                        print(r)
                        
                        
                        
                        print("done -- get_topics")
                        
                    }
                    
                }else{
                    print("Resource.Article ERROR \(article.article!.id!)")
                }
            }
        }
    }

    
    
 
    
    
}
