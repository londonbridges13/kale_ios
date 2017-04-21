//
//  TopicDetailViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 12/1/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Kingfisher
import Hero

class TopicDetailViewController: UIViewController {

    @IBOutlet var topicImageView: UIImageView!

    @IBOutlet var topicLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    
    @IBOutlet var add_removeButton: UIButton!
    @IBOutlet var closeButton: UIButton!

    var topic_image: UIImage?
    var topic_title: String?
    var desc_text: String?
    var my_topics_count : Int?
    var should_add: Bool?
    var action: String? // may not be needed
    
    var blue = UIColor(colorLiteralRed: 29/255, green: 171/255, blue: 192/255, alpha: 1)
    var red = UIColor(colorLiteralRed: 228/255, green: 81/255, blue: 99/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topicImageView.layer.masksToBounds = true
        topicImageView.clipsToBounds = true
        topicImageView.layer.cornerRadius = 4

        self.add_removeButton.layer.cornerRadius = 4
        self.closeButton.addTarget(self, action: #selector(TopicDetailViewController.close_view), for: .touchUpInside)
        self.add_removeButton.addTarget(self, action: #selector(TopicDetailViewController.close_view), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func close_view(){
        print("Closing View")
        self.dismiss(animated: true, completion: nil)
    }
    
    
//    func add_or_remove(){
//        // Check if the topic is in my topics, if so: remove (show remove button)
//        // if not: add (show add button)
//        
//    }
//    func pressed_add_or_remove(){
//        if self.should_add == true{
//            // run add_topic()
//            self.add_topic()
//        }else if self.should_add == false{
//            // run remove_topic()
//            self.remove_topic()
//        }
////    }
//    func add_topic(){
//        // Add topic to my topics
//        
//        //close view
//        self.close_view()
//    }
//    
//    func remove_topic(){
//        // Remove topic from my topics
//        
//        //close view
//        self.close_view()
//    }
    
    func download_image(image_url: String){
        // KingFisher download
        let url = URL(string: image_url)
        //        let image = UIImage(named: "default_profile_icon")
        topicImageView.kf.setImage(with: url)//, placeholder: image)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
