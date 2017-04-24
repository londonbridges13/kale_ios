//
//  Topic.swift
//  Undercooked - Content Tool
//
//  Created by Lyndon Samual McKay on 12/18/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import Foundation
import UIKit

class Topic {
    var id : Int?
    var title : String?
    var desc : String?
    var topic_image_url : String?
    var topic_image : UIImage?
//    var resources = [Resource]() // Array of Resources that are linked to this topic
    
    var articles = [Article]()
    var recent_articles_count : Int? //number of articles from the last two days, 3 is golden number
    
}
