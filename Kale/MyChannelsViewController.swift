//
//  MyChannelsViewController.swift
//  Kale
//
//  Created by Lyndon Samual McKay on 5/25/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Kingfisher
import RealmSwift
import Alamofire

class MyChannelsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GlimspeChannelCellDelegate {
    
    @IBOutlet var tableview: UITableView!
    @IBOutlet var more_channelsButton: UIButton!
    @IBOutlet var channel_countLabel: UILabel!
    
    var channels = [Resource]()
    var selected_channels = 0 // number of selected channels
    var topic_ids = [Int]()
    var delegate : ContinueDismissDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        more_channelsButton.layer.cornerRadius = 4
//        more_channelsButton.addTarget(self, action: #selector(SuggestedChannelsViewController.pressed_done), for: .touchUpInside)
        tableview.delegate = self
        tableview.dataSource = self
        // Do any additional setup after loading the view.
        get_recommended_channels()
        update_selected_channels()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channels.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        // Display Channel Cell
        let indexx = indexPath.row
        let cell : GlimspeChannelCell = tableview.dequeueReusableCell(withIdentifier: "GlimspeChannelCell", for: indexPath) as! GlimspeChannelCell
        cell.delegate = self
        
        cell.channel_id = channels[indexx].id!
        if channels.count > 0 && channels[indexx] != nil{
            if channels[indexx].blogger != nil{
                cell.titleLabel.text = channels[indexx].blogger!
            }
            
            if channels[indexx].blogger_image_url != nil{
                cell.get_channel_image(url: channels[indexx].blogger_image_url!)
                cell.pictureImageView.backgroundColor = UIColor.clear
            }
            
        }
        cell.get_channel_articles()
        cell.is_subscribed(id: channels[indexx].id!)
        
        self.update_selected_channels()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
            // Glimpse Channel Cell Height
            return 362
    }
    
    
    
    
    
    
    func get_recommended_channels(){
        
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!
//                "utopics": topic_ids
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/resources/my_channels", method: .post, parameters: parameters).responseJSON { (response) in
                if let articles = response.result.value as? NSArray{
                    for each in articles{
                        if let article = each as? NSDictionary{
                            var c = Resource()
                            var id = article["id"] as? Int
                            if id != nil{
                                c.id = id!
                            }
                            var title = article["title"] as? String
                            if title != nil{
                                c.blogger = title!
                            }
                            var desc = article["desc"] as? String
                            if desc != nil{
                                c.desc = desc!
                            }
                            var article_image_url = article["article_image_url"] as? String
                            if article_image_url != nil{
                                c.blogger_image_url = "\(article_image_url!)"
                            }
                            
                            
                            self.channels.append(c)
                            
                        }
                        
                        self.tableview.reloadData()
                    }
                    
                }else{
                    // nil result
                    print("loaded_all_channels")
                    print(response.result.value)
                }
            }
        }
        
    }
    
    
    
    func update_selected_channels(){
        // recount the number of selected_channels
        // I'm going to set this in the tableview load cell, so that the channel_countlabel can continuously update
        //run in delegate or add target to button
        
        if selected_channels == 1{
            self.channel_countLabel.text = "\(selected_channels) Channel"
        }else{
            self.channel_countLabel.text = "\(selected_channels) Channels"
        }
    }
    
    
    
    
    func add_one_to_channel_count(){
        print("Adding One")
        selected_channels += 1
        update_selected_channels()
    }
    
    func subtract_one_to_channel_count(){
        print("Subtrating One")
        if selected_channels != 0{
            selected_channels -= 1
            update_selected_channels()
        }
        update_selected_channels()
    }
    
    
    
    func pressed_done(){
        //unwind segue, delete this func it's useless
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
