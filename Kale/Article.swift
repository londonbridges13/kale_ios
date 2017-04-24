//
//  Article.swift
//  Undercooked - Content Tool
//
//  Created by Lyndon Samual McKay on 12/18/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import Foundation
import UIKit

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

}
