//
//  SelectTopicViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 12/1/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Jelly
import RealmSwift
import Alamofire

class SelectTopicViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var topicCountLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var collectionview: UICollectionView!
    
    var jellyAnimator: JellyAnimator?
    var topics = [Topic]()
    var my_topics = [Topic]()
    var selected_image : UIImage?
    var selected_topic : Topic?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionview.delegate = self
        collectionview.dataSource = self
        doneButton.layer.cornerRadius = 4
        // Do any additional setup after loading the view.
        self.get_topics()
        self.doneButton.addTarget(self, action: #selector(SelectTopicViewController.done_pressed), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //collectionview
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        topicCountLabel.text = "\(self.my_topics.count)/5"
        return topics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : Topic_CollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Topic_CollectionCell", for: indexPath) as! Topic_CollectionCell
        
        if topics[indexPath.row].topic_image_url != nil{
            cell.download_image(image_url: topics[indexPath.row].topic_image_url!)
        }
        if topics[indexPath.row].title != nil{
            cell.topicLabel.text = topics[indexPath.row].title!
        }
        cell.layoutIfNeeded()

       
//        cell.topicImageView.layer.masksToBounds = true
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Display TopicDetailViewController
        let cell : Topic_CollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Topic_CollectionCell", for: indexPath) as! Topic_CollectionCell
        if cell.topicImageView.image != nil{
            self.selected_image = cell.topicImageView.image!
        }
        self.display_topic(topic: topics[indexPath.row])
    }

    
    
    func get_topics(){
        print("running get_topics")
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.client_token != nil{
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!
//                "utoken": user!.access_token!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/topics/display_topics", method: .post, parameters: parameters).responseJSON { (response) in
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
    

    func not_enough_alert(){
        let alertController = UIAlertController(title: "Hold up!", message: "Select up to 5 Topics", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            print("You pressed OK")
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
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
        
        // checking my_topics for this topic
        var my_topic_ids = [Int]()
        for each in my_topics{
            if each.id != nil{
                my_topic_ids.append(each.id!)
            }
        }
        if my_topic_ids.contains(topic.id!) == false{
            // present add_topic option, set should_add = true
            viewController.should_add = true
            viewController.add_removeButton.addTarget(self, action: #selector(SelectTopicViewController.add_topic), for: .touchUpInside)
        }else{
            //my_topics already has this topics, present remove option
            viewController.should_add = false
            viewController.add_removeButton.addTarget(self, action: #selector(SelectTopicViewController.remove_topic), for: .touchUpInside)
            viewController.add_removeButton.setTitle("Remove", for: .normal)
            var red = UIColor(colorLiteralRed: 220/258, green: 98/255, blue: 111/255, alpha: 1)
            viewController.add_removeButton.backgroundColor = red

        }
        viewController.my_topics_count = self.my_topics.count
        
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
    
    
    func add_topic(){
        if self.selected_topic != nil{
            // there is a selected_topic, add it to my topics
            // if it isn't already there
            var my_topic_ids = [Int]()
            for each in my_topics{
                if each.id != nil{
                    my_topic_ids.append(each.id!)
                }
            }
            if my_topic_ids.contains(selected_topic!.id!) == false{
                // add selected image to my topics
                self.my_topics.append(selected_topic!)
                self.collectionview.reloadData()
                // this reload is for updating the counter label
                print("Added topic the the list")
            }else{
                print("Add_topic should not be running, my_topics already contains this topic")
            }
        }
    }
    
    func remove_topic(){
        // using selected_topic
        var id = selected_topic?.id
        if id != nil{
            if my_topics.contains(where: {$0.id == id}){
                // remove topic
                let index = my_topics.index(where: {$0.id == id})
                my_topics.remove(at: index!)
                print("Removed Topic")
                self.collectionview.reloadData()
            }
            
        }
    }
    
    func done_pressed(){
        if my_topics.count <= 5 && my_topics.count >= 3{
            self.submit_topics()
        }else{
            // user needs to add more topics, or they added too many
            print("Not enough Topics")
            self.not_enough_alert()
        }
    }
    func submit_topics(){
        // send and save topics as this user, then segue over Home Tab once completed
        let realm = try! Realm()
        var user = realm.objects(User).first
        if  user?.client_token != nil && user?.access_token != nil{
            print("submitting topics")
            var utopics = [Int]()
            for each in self.my_topics{
                utopics.append(each.id!)
            }
            print(my_topics.count)
            print("Look up")
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!,
                "utopics": utopics
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/topics/addtopics", method: .post, parameters: parameters).responseJSON { (response) in
                if let result = response.result.value as? String{
                    print(result)
                }
                print(response.result.value as? String)
                self.go_home()
            }
        }
        
    }
    
    func go_home(){
        performSegue(withIdentifier: "st_h", sender: self)
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
