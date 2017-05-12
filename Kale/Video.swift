//
//  Video.swift
//  Kale
//
//  Created by Lyndon Samual McKay on 5/12/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import Foundation
import UIKit


class Video {
    var id : Int?
    var title : String?
    var desc : String?
    var video_url : String?
    var video_date : Date?
    var display_topic : String?
    var video_image_url : String?
    var video_image : UIImage?
    var resource_title : String? // Title of Resource
    var resource : Resource?
    
    var likes = 0
    var user_like = false
    var set_likes = false // this assures us that the video has grabbed the latest likes and we shouldn't have to reload them
    //    var topics
    
}
