//
//  HomeViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 12/1/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Jelly
import NVActivityIndicatorView
import RealmSwift
import Alamofire
import Kingfisher
import PullToMakeSoup
import Foundation
import AMScrollingNavbar
//import RAReorderableLayout

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout, RAReorderableLayoutDelegate, RAReorderableLayoutDataSource, ArtcleCellDelegate {// UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var tableview: UITableView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var header: UIView!
    @IBOutlet var statusbar_view: UIView!
    @IBOutlet var topicLabel : UILabel!
    

    var actIndi : NVActivityIndicatorView?
    var jellyAnimator: JellyAnimator?
    var selected_topic = "Handpicked"
    var selected_topic_id = 0
    var selected_topic_image : String? // url
    var selected_handpicked = true // checks if the handpicked topic was selected
    var topics = [Topic]()
    var articles = [Article]()
    var videos = [Video]()
    var results = [Searchable]() // All Results, Products, Articles, Ads, Promotions
    var topic_viewed = "Handpicked"
    var selected_article_url : String?
    var selected_article : Article?
    var channel_id : Int?
    var selected_video: Video?
    var loadedHomeVC = false
    var loaded_all_cells = false
    var isNewDataLoading = false
    var pagination = 1
    //var dragAndDropManager : KDDragAndDropManager?

    override func viewDidLoad(){
        super.viewDidLoad()
        
       self.collectionView.delegate = self
       self.collectionView.dataSource = self
        (collectionView.collectionViewLayout as! RAReorderableLayout).scrollDirection = .horizontal

        self.tabBarController?.tabBar.isHidden = true

        let pop_blue = UIColor(colorLiteralRed: 29/255, green: 171/255, blue: 184/255, alpha: 1)
        let off_white = UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 247/255, alpha: 1)
        header.backgroundColor = off_white
        statusbar_view.backgroundColor = off_white
        
        set_first_topic()
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.topicLabel.text = self.selected_topic
        self.inform_user()
        
        if loadedHomeVC == false{
            self.start_loading(load_time: 4)
        }
        
        var delayInSeconds = 2.60
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            self.does_user_exist()
        }
        self.check_time_to_get_feedback()
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // self.check_for_requery() no longer needed 
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default//.lightContent
    }
    
    func initial_load(){
        // if user exists (with name and email), then display regular load
        // else go to loadingVC
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            print("User Exists")
            if loadedHomeVC == false{
                self.display_user_view()
            }else{
                self.display_floating_tab_bar()
            }
            self.get_topics()
            self.get_handpicked_articles()
        }else{
            // no longer needed, this is down in the "does_user_have_topics" and "does_user_exist"
            // go to loadVC which will redirect you to onboarding
            print("Open loadingVC")
            
            var loadVC = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            self.view.addSubview(loadVC.view)
            self.addChildViewController(loadVC)

        }
    }
    
    func does_user_exist(){
        print("Checking for user")
        //display loading for 2 seconds, to hide the validation
        if loadedHomeVC == false{
            // won't load everytime user loads home tab
//            start_loading(load_time: 5)
        }
        var answer : String?
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "uemail": user!.email!
            ]
            print("User Token: \(user!.access_token!)")
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/users/does_user_exist", method: .post, parameters: parameters).responseJSON { (response) in
                if response.result.value != nil{
                    if let result = response.result.value as? String {
                        print("Does User Exist: \(result)")
                        answer = result
                        if answer == "no"{
                            // load_vc
                            self.load_VC()
                        }else{
                            self.does_user_have_topics()
                        }
                    }
                }
            }
        }else{
            // no user, go to onboard
//            self.segue_to_onboarding()
            self.load_VC()
        }
    }
    
    
    
    func does_user_have_topics(){
        print("Checking for user")
        var answer : String?
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "uemail": user!.email!
            ]
            print("User Token: \(user!.access_token!)")
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/users/does_user_have_topics", method: .post, parameters: parameters).responseJSON { (response) in
                if response.result.value != nil{
                    if let result = response.result.value as? String {
                        print("Does User Have Topics: \(result)")
                        answer = result
                        if answer == "no"{
                            self.load_VC()
                        }else{
                            // Run the initial load
                            self.initial_load()
                        }
                    }
                }
            }
        }
        
    }

    
    
    func load_VC(){
//        performSegue(withIdentifier: "loadVC", sender: self)
        
        print("Open loadingVC")
        
        var loadVC = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
//        present(loadVC, animated: true, completion: nil)
        self.view.addSubview(loadVC.view)
        self.addChildViewController(loadVC)

    }
    
    //collectionView
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.topics.count  // for handpicked articles
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var index = indexPath.row //+ 1 // use this for all other indexpaths, but not the first
        
        if topics[indexPath.row].title == "Handpicked"{ // this line is important, it allows for the handpicked query to move as the others
            let cell: Topic_CollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeadTopic_CollectionCell", for: indexPath) as! Topic_CollectionCell
            
            
            cell.topicLabel.text = "Handpicked"
            cell.topicImageView.image = UIImage(named: "handpicked")
            cell.board.layer.cornerRadius = 4
//            cell.topicLabel.layer.borderWidth = 1
            cell.topicLabel.layer.borderColor = UIColor.white.cgColor
            cell.topicLabel.layer.cornerRadius = 6
//            cell.board.backgroundColor = UIColor.clear

            return cell
        }else{
            let cell: Topic_CollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeadTopic_CollectionCell", for: indexPath) as! Topic_CollectionCell
            
            cell.topicImageView.image = UIImage(named: "handpicked")

            cell.topicImageView.layer.shadowColor = UIColor.black.cgColor
            cell.topicImageView.layer.shadowOpacity = 1
            cell.topicImageView.layer.shadowOffset = CGSize.zero
            cell.topicImageView.layer.shadowRadius = 2

            cell.board.layer.cornerRadius = 4
            cell.topicImageView.layer.masksToBounds = true
            // i dont know if any of this works
            
//            cell.topicLabel.layer.borderWidth = 1
            cell.topicLabel.layer.borderColor = UIColor.white.cgColor
            cell.topicLabel.layer.cornerRadius = 6

            if self.topics[index].title != nil{
                cell.topicLabel.text = self.topics[index].title!
            }
            
            if self.topics[index].topic_image_url != nil{
                let url = URL(string: "\(self.topics[index].topic_image_url!)")
                cell.topicImageView.kf.setImage(with: url)
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var index = indexPath.row //+ 1 // use this for all other indexpaths, but not the first
        
        if topics[indexPath.row].title == "Handpicked"{
            var handpicked = "Handpicked"
            self.topic_viewed = handpicked//self.topics[index].title!
            self.selected_topic = handpicked//self.topics[index].title!
            self.topicLabel.text = handpicked
            self.selected_topic_image = ""
            self.selected_handpicked = true
//            self.selected_topic_image = UIImage(named: "")
            self.results.removeAll()
            self.start_loading()
            
            var delayInSeconds = 0.35
            // I deleyed the process because I didn't want the user to see the content load before the loading screen appeared.
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                self.get_handpicked_articles()
            }
            
        }else{
            self.results.removeAll()

            self.selected_handpicked = false
            if self.topics[index].title != nil{
                self.topic_viewed = self.topics[index].title!
                self.selected_topic = self.topics[index].title!
            }
            self.start_loading()
            
            var delayInSeconds = 0.35
            // I deleyed the process because I didn't want the user to see the content load before the loading screen appeared.
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                if self.topics[index].title != nil{
                    self.topic_viewed = self.topics[index].title!
                    self.selected_topic = self.topics[index].title!
                    self.selected_topic_id = self.topics[index].id!
                }
                if self.topics[index].id != nil{
                    self.get_topic_articles(topic_id: self.topics[index].id!)
                }
                if self.topics[index].topic_image_url != nil{
                    self.selected_topic_image = self.topics[index].topic_image_url!
                }
                self.topicLabel.text = self.topics[index].title!
            }
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, at: IndexPath, willMoveTo toIndexPath: IndexPath) {
        print()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, at: IndexPath, didMoveTo toIndexPath: IndexPath) {
        
        let new = self.topics[toIndexPath.row]
        let old = self.topics[at.row]
        print(old.title)
        print(new.title)
        topics.remove(at: at.row )
        topics.insert(old, at: toIndexPath.row )
        
        update_topic_order()
    }
    
    func scrollTrigerEdgeInsetsIncollectionView(_ collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 50, 0, 50)
    }
    
    func scrollSpeedValueIncollectionView(_ collectionView: UICollectionView) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var sizingNibNew = Topic_CollectionCell()

//        let width = collectionView.frame.size.width - collectionView.sectionInset.left - collectionView.sectionInset.right

        let width = sizingNibNew.systemLayoutSizeFitting(CGSize(width: .max, height: 85), withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityFittingSizeLevel).height


        return CGSize(width: width, height: 85)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(3, 5, 0, 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }


    


    
    //tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count + 2 // For header cell and loading cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var indexx = indexPath.row - 1
        if indexPath.row == 0{
            let cell : TopicHeaderCell = tableview.dequeueReusableCell(withIdentifier: "TopicHeaderCell", for: indexPath) as! TopicHeaderCell
            cell.topicLabel.text = "" //self.selected_topic // when you removed this cell sometimes less is more 
            if self.selected_handpicked == true{
                cell.topicImageView.image = UIImage(named: "handpicked")
                cell.topicImageView.layer.cornerRadius = 5
            }else if self.selected_topic_image != nil{
                let url = URL(string: "\(self.selected_topic_image!)")
                cell.topicImageView.kf.setImage(with: url)
            }
            tableView.rowHeight = 322
            return cell
        }else if indexPath.row > results.count{
            //LoadingCell
            let cell : LoadingCell = tableview.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
       
            
            if !isNewDataLoading{
                pagination += 1
                isNewDataLoading = true
                if selected_topic == "Handpicked"{
                    print("getting more handpicked")
//                    continue_handpicked_articles()
                }else{
                    print("getting more \(selected_topic)")
                    continue_topic_articles(topic_id: selected_topic_id)
                }
            }
          

            if loaded_all_cells == true{
                // display "All Done" label

            }

            
            
            return cell
        }else if results.count > indexx && results[indexx].article != nil{
            // Display articles
            let cell: V2ArticleCell = tableview.dequeueReusableCell(withIdentifier: "V2ArticleCell", for: indexPath) as! V2ArticleCell
            
            cell.delegate = self
            if results[indexx].article != nil{
                cell.l_article = results[indexx].article!
            }
//            cell.topicLabel.text = self.selected_topic
            if results[indexx].article!.title != nil{
                cell.titleLabel.text = results[indexx].article!.title!
            }
            if results[indexx].article!.desc != nil{
                cell.descLabel.text = results[indexx].article!.desc!
            }
            if results[indexx].article!.resource != nil && results[indexx].article!.resource?.blogger != nil{
                cell.bloggerLabel.text = results[indexx].article!.resource?.blogger!
                cell.channel_id = results[indexx].article!.resource?.id!

            }
            if results[indexx].article!.resource != nil && results[indexx].article!.resource?.blogger_image_url != nil{
//                cell.channelButton.addTarget(self, action: #selector(HomeViewController.segue_to_channel), for: .touchUpInside)
                cell.get_blogger_image(url: results[indexx].article!.resource!.blogger_image_url!)
            }
            if results[indexx].article!.article_image_url != nil{
                
                cell.get_article_image(url: results[indexx].article!.article_image_url!)
                cell.articleImageView.backgroundColor = UIColor.clear
            }
            if results[indexx].article!.article_date != nil{
                let date = results[indexx].article!.article_date!
                
                cell.dateLabel.text = date.dashedStringFromDate()
            }
            
       

            if cell.l_article != nil{
                if cell.l_article!.set_likes == false {
                    // load cell here
                    cell.likeCountLabel.text = ""
                    cell.likeButton.isSelected = false
                }else{
                    // set like count label and heartbutton
                    if cell.l_article!.likes == 0{
                        cell.likeCountLabel.text = ""
                    }else{
                        cell.likeCountLabel.text = "\(cell.l_article!.likes)"
                    }
                }
                
                if cell.l_article!.user_like == true{
                    // full red circle
                    cell.likeButton.setImage(UIImage(named: "selected heart icon"), for: .normal)
                }else{
                    cell.likeButton.setImage(UIImage(named: "red heart icon"), for: .normal)
                }
            }else{
                // can't find article, set default like button
                cell.likeButton.setImage(UIImage(named: "red heart icon"), for: .normal)
                cell.likeCountLabel.text = ""
            }
            
            

            cell.shareButton.tag = indexx
            cell.shareButton.addTarget(self, action: #selector(HomeViewController.share_article), for: .touchUpInside)
            tableView.estimatedRowHeight = 615
            
            if results.count == indexPath.row{
                isNewDataLoading = false
                print("isNewDataLoading = false")
            }
            
            return cell
        }else if results.count > indexx && results[indexx].video != nil{
            let cell: VideoCell = tableview.dequeueReusableCell(withIdentifier: "VideoCellHome", for: indexPath) as! VideoCell
            print("Showing video cell")
            // title
            if results[indexx].video!.title != nil{
                cell.titleLabel.text = results[indexx].video!.title!
            }
            // video image
            if results[indexx].video!.video_image_url != nil{
                cell.get_video_image(url: results[indexx].video!.video_image_url!)
            }
            
            // shadow 
//            cell.borderView.layer.shadowColor = UIColor.black.cgColor
//            cell.borderView.layer.shadowOpacity = 0.6
//            cell.borderView.layer.shadowOffset = CGSize(width: 0, height: 0.7)
//            cell.borderView.layer.shadowRadius = 1.2
            
            tableView.estimatedRowHeight = 275

            return cell
        }else{// if results.count > 0 && results[indexx].product != nil{
            // Display ProductCell
            let cell: ProductCell = tableview.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
            
            cell.selectionStyle = UITableViewCellSelectionStyle.default
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var indexx = indexPath.row - 1
        if indexPath.row == 0{
            //Header Cell
            return 40//90//322 //shrinking for a better look (sometimes less is more)
        }else if results.count > indexx && results[indexx].product != nil{
            return 92
        }else if results.count > indexx && results[indexx].video != nil{
            return 275 //UITableViewAutomaticDimension // 275
        }else if indexPath.row > results.count{
            // Bottom, LoadingCell
            return 130
        }else{// if results.count > 0 && results[indexx].product != nil{
            //Article
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var indexx = indexPath.row - 1
        if indexPath.row == 0{
            //Header Cell, do nothing
        }else if results[indexx].product != nil{
            self.display_product()
        }else if results[indexx].article != nil{
            // visit article url
            self.selected_article = results[indexx].article!
            if results[indexx].article!.article_url != nil{
                self.visit_article(url: results[indexx].article!.article_url!)
            }else{
                print("ITS NIL")
            }
        }else if results[indexx].video != nil{
            if results[indexx].video!.video_url != nil{
                self.selected_article_url = results[indexx].video!.video_url!
                self.selected_video = results[indexx].video!
            }
            self.segue_to_video()
        }
        tableview.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.row > results.count{
//            // this is for the loadingcell
//            let cell : LoadingCell = tableview.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
//            cell.awakeFromNib()
//        }

    }
    
    
    // scrolling for hiding navbar :D
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrolling")
        
        if self.tableview.panGestureRecognizer.translation(in: self.tableview).y < 0.0{
            var offset = self.tableview.panGestureRecognizer.translation(in: self.tableview).y
            if offset > 0{
                offset = offset * -1
            }
            let up = CGAffineTransform(translationX: 0, y: -33)//-83)
            UIView.animate(withDuration: 0.600, animations: {
                self.header?.transform = up
            })
        }else{
            var offset = self.tableview.panGestureRecognizer.translation(in: self.tableview).y
            if offset > 0{
                offset = offset * -1
            }
            let up = CGAffineTransform(translationX: 0, y: 0)
            UIView.animate(withDuration: 0.600, animations: {
                self.header?.transform = up
            })
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //Bottom Refresh
        print("Bottom Refresh, getting more results")

        
//            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
//            {
//                if !isNewDataLoading{
//                    
//                    pagination += 1
//                    isNewDataLoading = true
//                    if selected_topic == "Handpicked"{
//                        print("getting more handpicked")
//                        continue_handpicked_articles()
//                    }else{
//                        print("getting more \(selected_topic)")
//                        continue_topic_articles(topic_id: selected_topic_id)
//                    }
//                }
//            }
    }
    
    
    func update_topic_order(){
        // save the user's topic order
        // send a request, used 0 for the id of Handpicked topic
        // first grab all the topics' ids
        var ids = [Int]()
        for each in topics{
            if each.id != nil{
                ids.append(each.id!)
            }
        }
        
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!,
                "topic_ids": ids
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/users/update_topic_order", method: .post, parameters: parameters).responseJSON { (response) in
                // no response needed
                print(response.result.value)
            }
        }
        
    }
    
    
    func set_first_topic(){
        var first_topic = Topic() // handpicked
        first_topic.title = "Handpicked"
        first_topic.id = 0
        self.topics.append(first_topic)

    }
    
    func get_topics(){
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/topics/get_topics", method: .post, parameters: parameters).responseJSON { (response) in
                if let topicss = response.result.value as? NSArray{
                    for each in topicss{
                        if let topic = each as? NSDictionary{
                            // Inside Topic
                            var t = Topic()
                            var title = topic["title"] as? String?
                            if title != nil{
                                t.title = title!
                            }
                       
                            var id = topic["id"] as? Int
                            if id != nil{
                                t.id = id!
                            }
//                            self.topics.append(t)
                            self.get_topic_image(topic: t)
                            print(t)
                            print("done -- get_topics")
                            self.collectionView.reloadData()
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
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/topics/get_topic_image", method: .post, parameters: parameters).responseJSON { (response) in
                //                print(response.result.value!)
                let topic_image_url = "\(response.result.value!)"
                print(topic_image_url)
                topic.topic_image_url = topic_image_url
                self.topics.append(topic)
                self.collectionView.reloadData()
                print("done -- get_topic_image")
            }
        }
    }

    
    func get_topic_articles(topic_id: Int){
        pagination = 1
        loaded_all_cells = false
        self.results.removeAll()
        
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utopic": topic_id,
                "page": pagination
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/topics/display_topic_articles", method: .post, parameters: parameters).responseJSON { (response) in
                if let articles = response.result.value as? NSArray{
                    for each in articles{
                        if let article = each as? NSDictionary{
                            var resource_type = article["resource_type"] as? String
                            if resource_type != nil{
                                print("ResourceType : \(resource_type)")
                                if resource_type!.contains("video"){
                                    // It's an video
                                    print("Found a video")
                                    // Inside Video
                                    var v = Video()
                                    var id = article["id"] as? Int
                                    if id != nil{
                                        v.id = id!
                                    }
                                    var title = article["title"] as? String
                                    if title != nil{
                                        v.title = title!
                                    }
                                    var desc = article["desc"] as? String
                                    if desc != nil{
                                        v.desc = desc!
                                    }
                                    var article_image_url = article["article_image_url"] as? String
                                    if article_image_url != nil{
                                        v.video_image_url = "\(article_image_url!)"
                                    }
                                    var article_url = article["article_url"] as? String
                                    if article_url != nil{
                                        v.video_url = "\(article_url!)"
                                    }
                                    var display_topic = article["display_topic"] as? String
                                    if display_topic != nil{
                                        v.display_topic = "\(display_topic!)"
                                    }
                                    var article_date = article["article_date"] as? String
                                    if article_date != nil{
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                        let date = dateFormatter.date(from: article_date!)
                                        print("date: \(date)")
                                        v.video_date = date!
                                    }
                                    
                                    var result = Searchable()
                                    self.videos.append(v)
                                    result.video = v
                                    self.results.append(result)

                                    
                                    //                            self.results.append(result)
                                    //                            print(v.desc)
                                    //                            print("\(self.results.count)")
                                    self.get_article_resource(article: result)
                                    //                            self.tableview.reloadData()
                                }else{
                                    // It's an article
                                    // Inside Article
                                    var a = Article()
                                    var id = article["id"] as? Int
                                    if id != nil{
                                        a.id = id!
                                    }
                                    var title = article["title"] as? String
                                    if title != nil{
                                        a.title = title!
                                    }
                                    var desc = article["desc"] as? String
                                    if desc != nil{
                                        a.desc = desc!
                                    }
                                    var article_image_url = article["article_image_url"] as? String
                                    if article_image_url != nil{
                                        a.article_image_url = "\(article_image_url!)"
                                    }
                                    var article_url = article["article_url"] as? String
                                    if article_url != nil{
                                        a.article_url = "\(article_url!)"
                                    }
                                    var display_topic = article["display_topic"] as? String
                                    if display_topic != nil{
                                        a.display_topic = "\(display_topic!)"
                                    }
                                    var article_date = article["article_date"] as? String
                                    if article_date != nil{
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                        let date = dateFormatter.date(from: article_date!)
                                        print("date: \(date)")
                                        a.article_date = date!
                                    }
                                    
                                    var result = Searchable()
                                    self.articles.append(a)
                                    result.article = a
                                    
                                    //                            self.results.append(result)
                                    //                            print(a.desc)
                                    //                            print("\(self.results.count)")
                                    self.get_article_resource(article: result)
                                    //                            self.tableview.reloadData()
                                }
                            }
                            self.tableview.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    
    func continue_topic_articles(topic_id: Int){
//        self.results.removeAll()
        
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utopic": topic_id,
                "page": pagination
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/topics/display_topic_articles", method: .post, parameters: parameters).responseJSON { (response) in
                if let articles = response.result.value as? NSArray{
                    for each in articles{
                        if let article = each as? NSDictionary{
                            var resource_type = article["resource_type"] as? String
                            if resource_type != nil{
                                print("ResourceType : \(resource_type)")
                                if resource_type!.contains("video"){
                                    // It's an video
                                    print("Found a video")
                                    // Inside Video
                                    var v = Video()
                                    var id = article["id"] as? Int
                                    if id != nil{
                                        v.id = id!
                                    }
                                    var title = article["title"] as? String
                                    if title != nil{
                                        v.title = title!
                                    }
                                    var desc = article["desc"] as? String
                                    if desc != nil{
                                        v.desc = desc!
                                    }
                                    var article_image_url = article["article_image_url"] as? String
                                    if article_image_url != nil{
                                        v.video_image_url = "\(article_image_url!)"
                                    }
                                    var article_url = article["article_url"] as? String
                                    if article_url != nil{
                                        v.video_url = "\(article_url!)"
                                    }
                                    var display_topic = article["display_topic"] as? String
                                    if display_topic != nil{
                                        v.display_topic = "\(display_topic!)"
                                    }
                                    var article_date = article["article_date"] as? String
                                    if article_date != nil{
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                        let date = dateFormatter.date(from: article_date!)
                                        print("date: \(date)")
                                        v.video_date = date!
                                    }
                                    
                                    var result = Searchable()
                                    self.videos.append(v)
                                    result.video = v
                
                                    self.results.append(result)
                                    
                                    //                            print(v.desc)
                                    //                            print("\(self.results.count)")
                                    self.get_article_resource(article: result)
                                    self.tableview.reloadData()

                                }else{
                                    // It's an article
                                    // Inside Article
                                    var a = Article()
                                    var id = article["id"] as? Int
                                    if id != nil{
                                        a.id = id!
                                    }
                                    var title = article["title"] as? String
                                    if title != nil{
                                        a.title = title!
                                    }
                                    var desc = article["desc"] as? String
                                    if desc != nil{
                                        a.desc = desc!
                                    }
                                    var article_image_url = article["article_image_url"] as? String
                                    if article_image_url != nil{
                                        a.article_image_url = "\(article_image_url!)"
                                    }
                                    var article_url = article["article_url"] as? String
                                    if article_url != nil{
                                        a.article_url = "\(article_url!)"
                                    }
                                    var display_topic = article["display_topic"] as? String
                                    if display_topic != nil{
                                        a.display_topic = "\(display_topic!)"
                                    }
                                    var article_date = article["article_date"] as? String
                                    if article_date != nil{
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                        let date = dateFormatter.date(from: article_date!)
                                        print("date: \(date)")
                                        a.article_date = date!
                                    }
                                    
                                    var result = Searchable()
                                    self.articles.append(a)
                                    result.article = a
                                    
                                    //                            self.results.append(result)
                                    //                            print(a.desc)
                                    //                            print("\(self.results.count)")
                                    self.get_article_resource(article: result)
                                    //                            self.tableview.reloadData()
                                }
                            }

                            self.tableview.reloadData()
                        }
                    }
                }else{
                    // nil result
                    print("loaded_all_cells")
                    print(response.result.value)
                    self.loaded_all_cells = true
                }
            }
        }
    }
    

    
    
    func get_handpicked_articles(){
        pagination = 1
        loaded_all_cells = false

        self.results.removeAll()
        print("Starting Handpicked_Query")
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/topics/handpicked_articles", method: .post, parameters: parameters).responseJSON { (response) in
                print(response.result.value)
                print("Handpicked_Query result above")
                if let articles = response.result.value as? NSArray{
                    for each in articles{
                        if let article = each as? NSDictionary{
                            
                            var resource_type = article["resource_type"] as? String
                            if resource_type != nil{
                                print("ResourceType : \(resource_type)")
                                if resource_type!.contains("video"){
                                    // It's an video
                                    print("Found a video")
                                    // Inside Video
                                    var v = Video()
                                    var id = article["id"] as? Int
                                    if id != nil{
                                        v.id = id!
                                    }
                                    var title = article["title"] as? String
                                    if title != nil{
                                        v.title = title!
                                    }
                                    var desc = article["desc"] as? String
                                    if desc != nil{
                                        v.desc = desc!
                                    }
                                    var article_image_url = article["article_image_url"] as? String
                                    if article_image_url != nil{
                                        v.video_image_url = "\(article_image_url!)"
                                    }
                                    var article_url = article["article_url"] as? String
                                    if article_url != nil{
                                        v.video_url = "\(article_url!)"
                                    }
                                    var display_topic = article["display_topic"] as? String
                                    if display_topic != nil{
                                        v.display_topic = "\(display_topic!)"
                                    }
                                    var article_date = article["article_date"] as? String
                                    if article_date != nil{
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                        let date = dateFormatter.date(from: article_date!)
                                        print("date: \(date)")
                                        v.video_date = date!
                                    }
                                    
                                    var result = Searchable()
                                    self.videos.append(v)
                                    result.video = v
                                    self.results.append(result)

                                    
                                    //                            self.results.append(result)
                                    //                            print(v.desc)
                                    //                            print("\(self.results.count)")
                                    self.get_article_resource(article: result)
                                    //                            self.tableview.reloadData()
                                }else{
                                    // It's an article
                                    // Inside Article
                                    var a = Article()
                                    var id = article["id"] as? Int
                                    if id != nil{
                                        a.id = id!
                                    }
                                    var title = article["title"] as? String
                                    if title != nil{
                                        a.title = title!
                                    }
                                    var desc = article["desc"] as? String
                                    if desc != nil{
                                        a.desc = desc!
                                    }
                                    var article_image_url = article["article_image_url"] as? String
                                    if article_image_url != nil{
                                        a.article_image_url = "\(article_image_url!)"
                                    }
                                    var article_url = article["article_url"] as? String
                                    if article_url != nil{
                                        a.article_url = "\(article_url!)"
                                    }
                                    var display_topic = article["display_topic"] as? String
                                    if display_topic != nil{
                                        a.display_topic = "\(display_topic!)"
                                    }
                                    var article_date = article["article_date"] as? String
                                    if article_date != nil{
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                        let date = dateFormatter.date(from: article_date!)
                                        print("date: \(date)")
                                        a.article_date = date!
                                    }
                                    
                                    var result = Searchable()
                                    self.articles.append(a)
                                    result.article = a
                                    
                                    //                            self.results.append(result)
                                    //                            print(a.desc)
                                    //                            print("\(self.results.count)")
                                    self.get_article_resource(article: result)
                                    //                            self.tableview.reloadData()
                                }
                            }
                        }
                    }
                }else if response.result.value == nil{
                    // nil result
                    self.loaded_all_cells = true
                }
            }
        }
    }

    
    func continue_handpicked_articles(){
//        self.results.removeAll()
        
        print("Continuing Handpicked_Query")
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/topics/handpicked_articles", method: .post, parameters: parameters).responseJSON { (response) in
                print(response.result.value)
                print("Handpicked_Query result above")
                if let articles = response.result.value as? NSArray{
                    for each in articles{
                        if let article = each as? NSDictionary{
                            var resource_type = article["resource_type"] as? String
                            if resource_type != nil{
                                print("ResourceType : \(resource_type)")
                                if resource_type!.contains("video"){
                                    // It's an video
                                    print("Found a video")
                                    // Inside Video
                                    var v = Video()
                                    var id = article["id"] as? Int
                                    if id != nil{
                                        v.id = id!
                                    }
                                    var title = article["title"] as? String
                                    if title != nil{
                                        v.title = title!
                                    }
                                    var desc = article["desc"] as? String
                                    if desc != nil{
                                        v.desc = desc!
                                    }
                                    var article_image_url = article["article_image_url"] as? String
                                    if article_image_url != nil{
                                        v.video_image_url = "\(article_image_url!)"
                                    }
                                    var article_url = article["article_url"] as? String
                                    if article_url != nil{
                                        v.video_url = "\(article_url!)"
                                    }
                                    var display_topic = article["display_topic"] as? String
                                    if display_topic != nil{
                                        v.display_topic = "\(display_topic!)"
                                    }
                                    var article_date = article["article_date"] as? String
                                    if article_date != nil{
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                        let date = dateFormatter.date(from: article_date!)
                                        print("date: \(date)")
                                        v.video_date = date!
                                    }
                                    
                                    var result = Searchable()
                                    self.videos.append(v)
                                    result.video = v
                                    self.results.append(result)

                                    
                                    //                            self.results.append(result)
                                    //                            print(v.desc)
                                    //                            print("\(self.results.count)")
                                    self.get_article_resource(article: result)
                                    //                            self.tableview.reloadData()
                                }else{
                                    // It's an article
                                    // Inside Article
                                    var a = Article()
                                    var id = article["id"] as? Int
                                    if id != nil{
                                        a.id = id!
                                    }
                                    var title = article["title"] as? String
                                    if title != nil{
                                        a.title = title!
                                    }
                                    var desc = article["desc"] as? String
                                    if desc != nil{
                                        a.desc = desc!
                                    }
                                    var article_image_url = article["article_image_url"] as? String
                                    if article_image_url != nil{
                                        a.article_image_url = "\(article_image_url!)"
                                    }
                                    var article_url = article["article_url"] as? String
                                    if article_url != nil{
                                        a.article_url = "\(article_url!)"
                                    }
                                    var display_topic = article["display_topic"] as? String
                                    if display_topic != nil{
                                        a.display_topic = "\(display_topic!)"
                                    }
                                    var article_date = article["article_date"] as? String
                                    if article_date != nil{
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                        let date = dateFormatter.date(from: article_date!)
                                        print("date: \(date)")
                                        a.article_date = date!
                                    }
                                    
                                    var result = Searchable()
                                    self.articles.append(a)
                                    result.article = a
                                    
                                    //                            self.results.append(result)
                                    //                            print(a.desc)
                                    //                            print("\(self.results.count)")
                                    self.get_article_resource(article: result)
                                    //                            self.tableview.reloadData()
                                }
                            }
                        }
                    }
                }else{
                    // nil result
                    print("loaded_all_cells")
                    print(response.result.value)
                    self.loaded_all_cells = true
                }
            }
        }
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
                        
                        // add to results and shuffle (handpicked)
//                        self.results.append(article)
                        if article.article != nil{
                            self.did_user_like_article(article: article.article!)
                        }
//                        if self.selected_handpicked == true{
//                            // shuffle the array
//                            self.results.shuffle()
//                        }else{
//                            // organize by dates
//                            
//                        }

                        print("done -- get_topics")
                        self.collectionView.reloadData()
                        self.tableview.reloadData()

                    }
                    
                }else{
                    print("Resource.Article ERROR \(article.article!.id!)")
                    self.tableview.reloadData()
                }
            }
        }
    }
    
    func get_resource_image(resource: Resource){
        //not needed
    }
    
    func organized_by_dates(){
        
    }

    func get_products(){
        // intial query, for all topics
        
    }
   
    func get_products_by_topic(topic : Topic){
        // for specific topic
        
    }
    
    
    
    
    //Share Article
    func share_article(sender:UIButton){
        // what happens when the share button is tapped
        // open activity controller to display sharing options
        
        // USE Button.TAG for the index of the article 
        var article = self.results[sender.tag].article!
        
        print("Displaying UIActivity Controller")
        let textToShare = "\(article.title!)\n"
        
        if let myWebsite = NSURL(string: "\(article.article_url!)") {
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivityType.airDrop]
            //
            
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }

    
    // Update Article Cell
    // when user likes the article or comments
    func update_article_cell(article : Article){
        // find this article in the array (by id), then update the article
//        if let index = results.index(where: { $0.article != nil && $0.article!.id == article.id! }) {
            // use index to update the array
//            print("Updating Cell: \(index)")
            article.set_likes = true
            var searchable = Searchable()
            searchable.article = article
            results.append(searchable)
//            results[index].article = article
            self.tableview.reloadData()
//        }else{
//            print("Didn't find index")
//        }
    }
    
    
    // View Channel
    func view_channel(channel_id: Int){
        self.channel_id = channel_id
        self.segue_to_channel()
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
    
    func did_user_like_article(article: Article){
        print("starting did_user_like_article")
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!,
                "uarticle" : article.id!
            ]
                Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/users/did_user_like_article", method: .post, parameters: parameters).responseJSON { (response) in
                    print("Result: \(response.result.value)")
                    self.get_article_likes(article: article)
                    if let result = response.result.value as? Bool{
                        article.user_like = result
//                        self.update_article_cell(article: article)

                        print("done did_user_like_article")
                    }
                }
        }
        
    }
    
    
    
    
    
    func check_for_requery(){
        // run this in the view will appear
        // this will query the user's topics and compare them to the topics already listed.
        // If the topics are the same there is no need to requery
        print("Checking for Requery")
        
        var topic_ids = [Int]()
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
                            var id = topic["id"] as? Int
                            if id != nil{
                                topic_ids.append(id!)
                            }
                            print("Grabbed Topics for Requery")
                        }
                    }
                    // we've collected all of the user's topic_ids. Now we compare them.
                    var reload = false
                    for each in self.topics{
                        if each.id != nil || each.id == 0{ // because it is the topic
                            if topic_ids.contains(each.id!) == false{
                                // contains new topic requery everything
                                reload = true
                                print("New Topic Found. Should Requery Everything")
                            }
                        }
                    }
                    if reload == true{
                        self.requery_all()
                    }else{
                        print("No New Topic Found. Everything is good")
                    }
                }
            }
        }

    }
    
    func requery_all(){
        // this grabs the user's topics, and then grabs products and articles based on those topics
        // here we are clearinga all arrays, then calling get_topics again
        print("Beginning Requery")

        self.topics.removeAll()
        self.results.removeAll()
        self.articles.removeAll()
        self.tableview.reloadData()
        
        self.set_first_topic()
        self.get_topics()
    }
    
    
    
    func check_time_to_get_feedback(){
        // did user open the app enough times to ask for feedback
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            if user!.launch_count > 25{
                // see if user has already given feedback, if not ask for it (segue to feedback)
                self.check_user_feedback()
            }
        }
    }
    
    func check_user_feedback(){
        //see if user has already given feedback
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/feedbacks/did_user_give_feedback", method: .post, parameters: parameters).responseJSON { (response) in
                if let check = response.result.value as? String{
                    if check == "yes"{
                        // user has already given feedback
                    }else if check == "no"{
                        // ask user for feedback
                        self.get_feedback()
                    }
                    print(response.result.value)
                }
            }
        }

    }
    
    
    func thanks_for_feedback(){
        print("Alert thanking the user")
        // display thanks alert for the user's cooperation
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Feedback-Thanks")
        viewController!.view.layer.shadowColor = UIColor.black.cgColor
        viewController!.view.layer.shadowOpacity = 0.6
        viewController!.view.layer.shadowOffset = CGSize(width: 0, height: 1.7)
        viewController!.view.layer.shadowRadius = 2
        
        let midy = 2
        let alertPresentation = JellySlideInPresentation(dismissCurve: .linear,
                                                         presentationCurve: .linear,
                                                         cornerRadius: 4,
                                                         backgroundStyle: .blur(effectStyle: .dark),
                                                         jellyness: .jelly,
                                                         duration: .normal,
                                                         directionShow: .top,
                                                         directionDismiss: .top,
                                                         widthForViewController: .custom(value:self.view.frame.width - 10),
                                                         heightForViewController: .custom(value:100),
                                                         horizontalAlignment: .center,
                                                         verticalAlignment: .top,
                                                         marginGuards: UIEdgeInsets(top: CGFloat(midy), left: 5, bottom: 30, right: 5))
        
        
        let presentation = alertPresentation
        self.jellyAnimator = JellyAnimator(presentation:presentation)
        self.jellyAnimator?.prepare(viewController: viewController!)
        self.present(viewController!, animated: true, completion: nil)
        
        
        let adelayInSeconds = 4.25
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + adelayInSeconds) {
            viewController!.dismiss(animated: true, completion: nil)
        }
    }
    
    // Update Alert - Swipe Topics
    func inform_user(){
        let realm = try! Realm()
        let user = realm.objects(User).first
        if user != nil{
            if user!.knows_to_swipe_topics == false{
                // user hasn't been informed of the swiping feature, inform them
                print("did not inform user")

                let adelayInSeconds = 0.25
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + adelayInSeconds) {
                    self.display_guide_for_topics()
                }
            }else{
                print("informed user")
            }
        }
    }
    func display_guide_for_topics(){
        //Jelly Animation required
        print("display_guide_for_topics")
        self.guided_user()
        let viewController : SwipeAllTopicsAlertViewController = self.storyboard?.instantiateViewController(withIdentifier: "SwipeAllTopicsAlertViewController") as! SwipeAllTopicsAlertViewController
        
        
        var midy = (self.view.frame.height / 2) - (300 / 2)
        let alertPresentation = JellySlideInPresentation(dismissCurve: .linear,
                                                         presentationCurve: .linear,
                                                         cornerRadius: 8,
                                                         backgroundStyle: .blur(effectStyle: .dark),
                                                         jellyness: .jellier,
                                                         duration: .normal,
                                                         directionShow: .bottom,
                                                         directionDismiss: .bottom,
                                                         widthForViewController: .custom(value:265),
                                                         heightForViewController: .custom(value:310),
                                                         horizontalAlignment: .center,
                                                         verticalAlignment: .top,
                                                         marginGuards: UIEdgeInsets(top: 150, left: 5, bottom: 40, right: 5))
        
        
        let presentation = alertPresentation
        self.jellyAnimator = JellyAnimator(presentation:presentation)
        self.jellyAnimator?.prepare(viewController: viewController)
        self.present(viewController, animated: true, completion: nil)
        

    }
    func guided_user(){
        // save knows_to_swipe_topics, so this alert doesn't show again
        let realm = try! Realm()
        let user = realm.objects(User).first
        if user != nil{
            try! realm.write{
                user!.knows_to_swipe_topics = true
            }
        }
    }

    
    func display_user_view(){
        // display profile cell and remove tab
        self.tabBarController?.tabBar.isHidden = true

        let alert = UserView()
        let xpp = 15//self.view.frame.width / 2 - (self.view.frame.width - 30 / 2)
        alert.frame = CGRect(x: CGFloat(xpp), y: self.view.frame.height - 85, width: self.view.frame.width - 30 , height: 75)
        alert.layer.shadowColor = UIColor.black.cgColor
        alert.layer.shadowOpacity = 0.6
        alert.layer.shadowOffset = CGSize(width: 1, height: 1.7)
        alert.layer.shadowRadius = 2
        alert.alpha = 0
        self.view.addSubview(alert)
        alert.fadeIn()
        alert.profileButton.addTarget(self, action: #selector(HomeViewController.segue_to_profile), for: .touchUpInside)
        alert.transform = CGAffineTransform(translationX: 0, y: 90)

        var delayInSeconds = 0.25
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            
            UIView.animate(withDuration: 0.450) {
                alert.transform = CGAffineTransform(translationX: 0, y: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.4) {
                UIView.animate(withDuration: 0.250) {
                    alert.transform = CGAffineTransform(translationX: 0, y: 90)
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                    self.display_floating_tab_bar()
                }
            }
        }
    }
    
    func display_floating_tab_bar(){
        // display profile cell and remove tab
        self.tabBarController?.tabBar.isHidden = true
        
        let alert = FloatingTabBar()
        let xpp = 15//self.view.frame.width / 2 - (self.view.frame.width - 30 / 2)
        alert.frame = CGRect(x: CGFloat(xpp), y: self.view.frame.height - 60, width: self.view.frame.width - 30 , height: 55)
        alert.layer.shadowColor = UIColor.black.cgColor
        alert.layer.shadowOpacity = 0.6
        alert.layer.shadowOffset = CGSize(width: 1, height: 1.3)
        alert.layer.shadowRadius = 2
        self.view.addSubview(alert)
        alert.profileButton.addTarget(self, action: #selector(HomeViewController.segue_to_profile), for: .touchUpInside)
        alert.homeButton.addTarget(self, action: #selector(HomeViewController.tapped_home_button), for: .touchUpInside)
        alert.transform = CGAffineTransform(translationX: 0, y: 90)
        
        var delayInSeconds = 0.25
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            
            UIView.animate(withDuration: 0.450) {
                alert.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        }
        
    }
    
    
    func display_tab_bar(view : UIView)-> UIView{
        
        let alert = FloatingTabBar()
        let xpp = 15//self.view.frame.width / 2 - (self.view.frame.width - 30 / 2)
        alert.frame = CGRect(x: CGFloat(xpp), y: view.frame.height - 60, width: view.frame.width - 30 , height: 55)
        alert.layer.shadowColor = UIColor.black.cgColor
        alert.layer.shadowOpacity = 0.6
        alert.layer.shadowOffset = CGSize(width: 1, height: 1.3)
        alert.layer.shadowRadius = 2
        view.addSubview(alert)
        
        return alert
    }
    
    func segue_to_profile(){
        // segue to profile using right swipe
        print("seguing")
        performSegue(withIdentifier: "segue_to_profile", sender: self)
    }
    
    func segue_to_video(){
        print("seguing")
        performSegue(withIdentifier: "view video", sender: self)
    }
    
    func segue_to_channel(){
        performSegue(withIdentifier: "view channel", sender: self)
    }
    
    func tapped_home_button(){
        // move to the top of the tableview
        self.tableview.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        
        
        // move the header (with collection view) down
        // had to delay time because header goes back when the tableview is scrolling
        var delayInSeconds = 0.5
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            let up = CGAffineTransform(translationX: 0, y: 0)
            UIView.animate(withDuration: 0.400, animations: {
                self.header?.transform = up
            })
        }

    }
    func start_loading(load_time: Double = 1.25){
        var yp = view.frame.height / 2 - ((view.bounds.width) / 2) - 50
        
        var loadview = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        let undercooked_image = UIImageView(frame: CGRect(x: loadview.frame.width / 2 - 23, y: loadview.frame.height / 2 - 96, width: 45, height: 76))
        undercooked_image.contentMode = .scaleAspectFit
        undercooked_image.image = UIImage(named: "white_k")
        
        let loadLabel = UILabel(frame: CGRect(x: 0, y: loadview.frame.height / 2 - 96, width: loadview.frame.width, height: 52))
        loadLabel.textColor = UIColor.darkGray
        loadLabel.textAlignment = .center
        loadLabel.font = UIFont(name: "SanchezSlab", size: 45)
        loadLabel.adjustsFontSizeToFitWidth = true
        loadLabel.minimumScaleFactor = 0.1
        loadLabel.text = self.topic_viewed
        loadview.addSubview(loadLabel)
            
//        loadview.addSubview(undercooked_image)
//        let red = UIColor(colorLiteralRed: 255/255, green: 103/255, blue: 102/255, alpha: 1)
        let pop_blue = UIColor(colorLiteralRed: 29/255, green: 171/255, blue: 184/255, alpha: 1)
        let off_white = UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 247/255, alpha: 1)

        loadview.backgroundColor = off_white
        loadview.alpha = 0
        self.view.addSubview(loadview)
        loadview.fadeIn(duration: 0.6)
        
        var delayInSeconds = 0.25
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            
            var size : CGFloat = 37
            var xxp = loadview.frame.width / 2 - (size / 2)
            var hp = loadview.frame.height / 2 - (size / 2)
            let frame = CGRect(x: xxp, y: hp, width: size, height: size)
            
            self.actIndi = NVActivityIndicatorView(frame: frame, type: .lineScale, color: UIColor.darkGray, padding: 3)
            self.actIndi?.startAnimating()
            self.actIndi?.alpha = 0
            
            loadview.addSubview(self.actIndi!)
            
            self.actIndi?.fadeIn(duration: 0.2)
        }
        
        delayInSeconds = load_time
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            loadview.fadeOut(duration: 0.6)
            self.tableview.reloadData()
        }

    }
    
    
    
    func display_product(){
        print("Opening Product")
        let viewController : ProductViewController = self.storyboard!.instantiateViewController(withIdentifier: "ProductView") as! ProductViewController
//        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "ProductView")
        
        let slideOverPresentation = JellySlideInPresentation(dismissCurve: .linear,
                                                             presentationCurve: .linear,
                                                             cornerRadius: 0,
                                                             backgroundStyle: .dimmed,
                                                             jellyness: .none,
                                                             duration: .normal,
                                                             directionShow: .left,
                                                             directionDismiss: .left,
                                                             widthForViewController: .halfscreen,
                                                             heightForViewController: .fullscreen,
                                                             horizontalAlignment: .left,
                                                             verticalAlignment: .top)
        
        
        let presentation = slideOverPresentation
        self.jellyAnimator = JellyAnimator(presentation:presentation)
        self.jellyAnimator!.prepare(viewController: viewController)
        self.present(viewController, animated: true, completion: nil)
        
    }

    func visit_article(url : String){
        self.selected_article_url = url
        
        segue_to_article()
    }
    
    func segue_to_article(){
        self.performSegue(withIdentifier: "view article", sender: self)
    }
    
    func get_feedback(){
        self.performSegue(withIdentifier: "feedback", sender: self)
    }
    // MARK: - Navigation

    @IBAction func unwind_to_HomeVC(segue : UIStoryboardSegue){
        
    }
    
    @IBAction func unwind_from_feedback(segue : UIStoryboardSegue){
        self.thanks_for_feedback()
    }
    
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "view article"{
            let vc : ArticleViewController = segue.destination as! ArticleViewController
            vc.article_url = selected_article_url!
            vc.article = self.selected_article
        }
        if segue.identifier == "feedback"{
            let vc: FeedbackViewController = segue.destination as! FeedbackViewController
            vc.from = "home"
        }

        if segue.identifier == "segue_to_profile"{
            if segue is CustomUnwindSegue {
                print("CustomUnwindSegue .Push")
                (segue as! CustomUnwindSegue).animationType = .Push
            }
        }
        if segue.identifier == "view video"{
            let vc : VideoViewController = segue.destination as! VideoViewController
            vc.url_string = selected_article_url!
            vc.current_video = self.selected_video!
            
        }
        if segue.identifier == "view channel"{
            let vc : ChannelViewController = segue.destination as! ChannelViewController
            vc.channel_id = channel_id!
        }
        
    }
    
//    override func segueForUnwinding(to toViewController: UIViewController, from fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
//        let segue = CustomSegue(identifier: identifier, source: fromViewController, destination: toViewController)
//        segue.animationType = .Push
//        return segue
//    }
    
}

extension UIView {
    func fadeIn(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
}

extension Foundation.Date {
    func dashedStringFromDate() -> String {
        let dateFormatter = DateFormatter()
        let date = self
        dateFormatter.dateFormat = "MMMM d"
        return dateFormatter.string(from: date)
    }
}

extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}


extension UIImage {
    func cropBottomImage(image: UIImage) -> UIImage {
        let height = CGFloat(image.size.height / 3)
        let rect = CGRect(x: 0, y: image.size.height - height, width: image.size.width, height: height)
        return cropImage(image: image, toRect: rect)
    }
    func cropImage(image:UIImage, toRect rect:CGRect) -> UIImage{
        let imageRef:CGImage = image.cgImage!.cropping(to: rect)!
        let croppedImage:UIImage = UIImage(cgImage:imageRef)
        return croppedImage
    }
}

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
