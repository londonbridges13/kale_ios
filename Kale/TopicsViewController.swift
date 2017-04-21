//
//  TopicsViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 12/31/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Jelly
import Alamofire
import RealmSwift

class TopicsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableview : UITableView!
    var topics = [Topic]() // user's topics
    var jellyAnimator: JellyAnimator?
    var selected_topic : Topic?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        tableview.delegate = self
        tableview.dataSource = self
        
        get_topics()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : DetailTopicTableViewCell = tableview.dequeueReusableCell(withIdentifier: "DetailTopicTableViewCell", for: indexPath) as! DetailTopicTableViewCell
        
        if topics[indexPath.row].desc != nil{
            cell.descLabel.text = topics[indexPath.row].desc!
        }
        if topics[indexPath.row].title != nil{
            cell.topicLabel.text = topics[indexPath.row].title!
        }
        if topics[indexPath.row].topic_image_url != nil{
            cell.download_image(image_url: topics[indexPath.row].topic_image_url!)
        }
        cell.topicImageView.layer.cornerRadius = 4
        
        tableview.rowHeight = UITableViewAutomaticDimension
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Display Detail topic with "change" option
        display_topic(topic: topics[indexPath.row])
        tableview.deselectRow(at: indexPath, animated: true)
    }
   
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 209
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
        
     
        viewController.add_removeButton.setTitle("Change", for: .normal)
        viewController.add_removeButton.addTarget(self, action: #selector(TopicsViewController.go_to_swap_topics), for: .touchUpInside)
    
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

    
    
    func get_topics(){
        self.topics.removeAll()
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/topics/get_topics", method: .post, parameters: parameters).responseJSON { (response) in
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
                            self.tableview.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    
    func get_topic_image(topic : Topic){
        //        var topic_image_url : String?
        
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
                var topic_image_url = "\(response.result.value!)"
                
                print(topic_image_url)
                topic.topic_image_url = topic_image_url
                self.topics.append(topic)
                self.tableview.reloadData()
                print("done -- get_topic_image")
            }
        }
    }

    
    
    func go_to_swap_topics(){
        let adelayInSeconds = 0.625
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + adelayInSeconds) {
            self.performSegue(withIdentifier: "t_sw", sender: self)
        }
    }
    
    
    
    
    @IBAction func unwind_to_topicsVC(segue : UIStoryboardSegue){
//        let adelayInSeconds = 0.225
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + adelayInSeconds) {
        get_topics()
//        }
    }
    
    
    
    
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "t_sw"{
            // Send old_topic
            let vc : SwapTopicsViewController = segue.destination as! SwapTopicsViewController
            vc.old_topic = self.selected_topic!
        }
    }
    
    
    
}
