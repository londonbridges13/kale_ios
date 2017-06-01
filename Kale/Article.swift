//
//  Article.swift
//  Undercooked - Content Tool
//
//  Created by Lyndon Samual McKay on 12/18/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Alamofire

class Article {
    var id : Int?
    var title : String?
    var desc : String?
    var article_url : String?
    var article_date : Date?
    var display_topic : String?
    var article_image_url : String?
    var article_image : UIImage?
    var resource_title : String? // Title of Resource
    var resource : Resource?
    
    var likes = 0
    var user_like = false
    var set_likes = false // this assures us that the article has grabbed the latest likes and we shouldn't have to reload them
//    var topics 

    
    func did_user_like_article(){
        print("starting did_user_like_article")
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!,
                "uarticle" : self.id!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/users/did_user_like_article", method: .post, parameters: parameters).responseJSON { (response) in
                print("Result: \(response.result.value)")
                self.get_article_likes(article: self)
                if let result = response.result.value as? Bool{
                    self.user_like = result
                    print("done did_user_like_article")
                }
            }
        }
    }
    
    func get_article_likes(article: Article){
        
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "uarticle" : article.id!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/articles/get_article_like_count", method: .post, parameters: parameters).responseJSON { (response) in
                if let count = response.result.value as? Int{
                    article.likes = count
                    
                    self.update_article_cell(article: article)
                    if count != 0{
                    }
                    print(response.result.value)
                }
            }
        }
    }
    
    
    
    func update_article_cell(article : Article) {
        // find this article in the array (by id), then update the article
      
        article.set_likes = true
        
    }
    
    func article_to_cell() -> V2ArticleCell{
        
        var cell = V2ArticleCell()
        
        
        if self.title != nil{
            cell.title = self.title!
        }
        if self.desc != nil{
            cell.desc = self.desc!
        }
        if self.resource != nil && self.resource?.blogger != nil{
            cell.blogger = self.resource?.blogger!
            cell.channel_id = self.resource?.id!
            
        }
        if self.resource != nil && self.resource?.blogger_image_url != nil{
            //                cell.channelButton.addTarget(self, action: #selector(HomeViewController.segue_to_channel), for: .touchUpInside)
//            cell.get_blogger_image(url: self.resource!.blogger_image_url!)
        }
        if self.article_image_url != nil{
            
//            cell.get_article_image(url: self.article_image_url!)
//            cell.articleImageView.backgroundColor = UIColor.clear
        }
        if self.article_date != nil{
            let date = self.article_date!
            
            cell.date = date.dashedStringFromDate()
        }
        
        
        
        if cell.l_article != nil{
            if cell.l_article!.set_likes == false {
                // load cell here
                cell.likeCount = ""
                cell.like_selected = false
            }else{
                // set like count label and heartbutton
                if cell.l_article!.likes == nil{//0{
                    cell.likeCount = ""
                }else{
                    let x = cell.l_article!.title!.numberOfVowels + cell.l_article!.likes
                    cell.likeCount = " \(x)"//" \(count)"
                    //                        cell.likeCountLabel.text = "\(cell.l_article!.likes)"
                }
            }
            
        }
        
        return cell
    }


}
