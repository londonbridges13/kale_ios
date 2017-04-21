//
//  SwapTopicsViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 12/31/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Jelly
import RealmSwift
import Alamofire

class SwapTopicsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    
    @IBOutlet var collectionview: UICollectionView!
    @IBOutlet var cancelButton: UIButton!
    
    var jellyAnimator: JellyAnimator?
    var topics = [Topic]() // swappable topics
    var selected_image : UIImage?
    var selected_topic : Topic?
    var old_topic : Topic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionview.delegate = self
        collectionview.dataSource = self
        self.cancelButton.layer.cornerRadius = 4
        // Do any additional setup after loading the view.
        self.get_topics()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //collectionview
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : Topic_CollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SwapTopic_CollectionCell", for: indexPath) as! Topic_CollectionCell
        
        if topics[indexPath.row].topic_image_url != nil{
            cell.download_image(image_url: topics[indexPath.row].topic_image_url!)
        }
        if topics[indexPath.row].title != nil{
            cell.topicLabel.text = topics[indexPath.row].title!
        }
        cell.topicImageView.layer.cornerRadius = 4
        //        cell.topicImageView.layer.masksToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Display TopicDetailViewController
        let cell : Topic_CollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SwapTopic_CollectionCell", for: indexPath) as! Topic_CollectionCell
        if cell.topicImageView.image != nil{
            self.selected_image = cell.topicImageView.image!
        }
        self.display_topic(topic: topics[indexPath.row])
    }
    
    
    
    func get_topics(){
        print("running get_swappable_topics")
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.client_token != nil{
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/topics/get_swappable_topics", method: .post, parameters: parameters).responseJSON { (response) in
                print("request called")
                if let topicss = response.result.value as? NSArray{
                    for each in topicss{
                        if let topic = each as? NSDictionary{
                            // Inside Topic
                            var t = Topic()
                            var title = topic["title"] as? String
                            if title != nil{
                                t.title = title!
                            }
                            var desc = topic["description"] as? String
                            if desc != nil{
                                t.desc = desc!
                            }
                            var id = topic["id"] as? Int
                            if id != nil{
                                t.id = id!
                            }
                            //                            self.topics.append(t)
                            self.get_topic_image(topic: t)
                            print(t)
                            print("done -- get_topics")
                            self.collectionview.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func get_topic_image(topic : Topic){
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!,
                "utopic": topic.id!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/topics/get_topic_image", method: .post, parameters: parameters).responseJSON { (response) in
                //                print(response.result.value!)
                let topic_image_url = "\(response.result.value!)"
                print(topic_image_url)
                topic.topic_image_url = topic_image_url
                self.topics.append(topic)
                self.collectionview.reloadData()
                print("done -- get_topic_image")
            }
        }
    }
    
    
    
    
    
    
    func display_topic(topic : Topic){
        self.selected_topic = topic
        
        let viewController : TopicDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "TopicDetailViewController") as! TopicDetailViewController
        
        var midy = (self.view.frame.height / 2) - (235 / 2)
        let alertPresentation = JellySlideInPresentation(dismissCurve: .linear,
                                                         presentationCurve: .linear,
                                                         cornerRadius: 8,
                                                         backgroundStyle: .blur(effectStyle: .dark),
                                                         jellyness: .jelly,
                                                         duration: .medium,
                                                         directionShow: .bottom,
                                                         directionDismiss: .bottom,
                                                         widthForViewController: .custom(value:310),
                                                         heightForViewController: .custom(value:235),
                                                         horizontalAlignment: .center,
                                                         verticalAlignment: .top,
                                                         marginGuards: UIEdgeInsets(top: midy, left: 5, bottom: 30, right: 5))
        
        
        let presentation = alertPresentation
        self.jellyAnimator = JellyAnimator(presentation:presentation)
        self.jellyAnimator?.prepare(viewController: viewController)
        self.present(viewController, animated: true, completion: nil)
        
        viewController.add_removeButton.setTitle("Select", for: .normal)
        viewController.add_removeButton.addTarget(self, action: #selector(SwapTopicsViewController.done_pressed), for: .touchUpInside)
        
        if topic.desc != nil{
            viewController.descLabel.text = topic.desc!
        }
        if topic.title != nil{
            viewController.topicLabel.text = topic.title!
        }
        if topic.topic_image_url != nil{
            viewController.download_image(image_url: topic.topic_image_url!)
        }
        
    }
    
    
    
    func done_pressed(){
            self.swap_topics()
    }
    func swap_topics(){
        // send and save topics as this user, then segue over Home Tab once completed
        let realm = try! Realm()
        var user = realm.objects(User).first
        if  user?.client_token != nil && user?.access_token != nil{
            print("swapping topics")
            
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!,
                "oldtopic": self.old_topic!.id!,
                "newtopic": self.selected_topic!.id!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/topics/swap_topics", method: .post, parameters: parameters).responseJSON { (response) in
                if let result = response.result.value as? String{
                    print(result)
                    self.go_to_topics()
                }
                print(response.result.value as? String)
            }
        }
    }
    
    func go_to_topics(){
        // unwind back to segue
        self.cancelButton.sendActions(for: .touchUpInside)
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
