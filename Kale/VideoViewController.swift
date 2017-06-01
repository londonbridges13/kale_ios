//
//  VideoViewController.swift
//  Kale
//
//  Created by Lyndon Samual McKay on 5/9/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import SnapKit
import YouTubePlayer
import Alamofire
import RealmSwift

class VideoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ArtcleCellDelegate {

    var player: BMPlayer!
    @IBOutlet var videoPlayer: YouTubePlayerView!
    @IBOutlet var tableview: UITableView!
    @IBOutlet var bottomView : UIView!
    @IBOutlet var likeButton : UIButton!
    @IBOutlet var likeCountLabel : UILabel!
//    @IBOutlet var navButton : UIButton!
    @IBOutlet var backButton : UIButton!
    @IBOutlet var unwind_homeVC_button: UIButton!
    @IBOutlet var unwind_proVC_button: UIButton!
    @IBOutlet var unwind_channelVC_button : UIButton!

    var url_string : String?
    var url : URL?
    var current_video: Video?
    var recommendations = [Searchable]()
    var pagination = 1
    var action: String?
    var timer = Timer()
    var reading_time = 0 // seconds
    var like_count: Int?
    var selected_channel : Int?
    var selected_article  : Article?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self

        create_youtube_video()
        self.likeCountLabel.text = ""
        self.track_reading()
        self.set_backward_navigation() // set where you are going
        
        if current_video != nil{
            self.did_user_like_video()
            self.get_video_likes()
            self.get_recommendations()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    @IBAction func unwind_to_VideoVC(segue : UIStoryboardSegue){
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Stop timer, send reading time
        self.send_reading_time()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            UIView.animate(withDuration: 0.45, delay: 0.0, options: [], animations: {
                
//                self.videoPlayer.transform = CGAffineTransform(scaleX: 2, y: 1.3)
                // fix here
//                var frame = CGRect(x: -20, y: 10, width: self.view.frame.width + 20, height: self.view.frame.width * (9.0/16.0))
//
//                self.videoPlayer.frame = CGRect(x: 0, y: 0, width: (self.view.frame.width), height: (self.view.frame.height))
                
            }, completion: { (finished: Bool) in
            })
            
        } else {
            print("Portrait")
            UIView.animate(withDuration: 0.45, animations: {
//                self.videoPlayer.transform = CGAffineTransform.identity

            })
        }
    }
    
    
    //tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommendations.count + 1 // for the VideoDescriptionCell
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var indexx = indexPath.row - 1
        if indexPath.row == 0{
            // Display VideoDescriptionCell
            let cell : VideoDescriptionCell = tableview.dequeueReusableCell(withIdentifier: "VideoDescriptionCell", for: indexPath) as! VideoDescriptionCell

            cell.shareButton.addTarget(self, action: "share_article", for: .touchUpInside)
            
            cell.channelButton.addTarget(self, action: "visit_this_channel", for: .touchUpInside)
            
            if current_video != nil{
                if current_video!.video_date != nil{
                    let date = current_video!.video_date!
                    cell.dateLabel.text = date.dashedStringFromDate()
                }
                // title
                if current_video!.title != nil{
                    cell.titleLabel.text = current_video!.title!
                }
                // blogger label
                if  current_video!.resource != nil{
                    //name
                    if current_video!.resource!.blogger != nil{
                        cell.resourceLabel.text = current_video!.resource!.blogger!
                    }
                    //image
                    if current_video!.resource!.blogger_image_url != nil{
                        cell.get_blogger_image(url: current_video!.resource!.blogger_image_url!)
                    }
                }else{
                    // get blogger details
                }
            }else{
                // cant load/find video
            }
            
            
            return cell
            
        }else if recommendations.count > indexx && recommendations[indexx].article != nil{
            // Display Article Cell
            
            let cell: V2ArticleCell = tableview.dequeueReusableCell(withIdentifier: "V2ArticleCellVideo", for: indexPath) as! V2ArticleCell
            
            cell.delegate = self
            if recommendations[indexx].article != nil{
                cell.l_article = recommendations[indexx].article!
            }
            //            cell.topicLabel.text = self.selected_topic
            if recommendations[indexx].article!.title != nil{
                cell.titleLabel.text = recommendations[indexx].article!.title!
            }
            if recommendations[indexx].article!.desc != nil{
                cell.descLabel.text = recommendations[indexx].article!.desc!
            }
            if recommendations[indexx].article!.resource != nil && recommendations[indexx].article!.resource?.blogger != nil{
                cell.bloggerLabel.text = recommendations[indexx].article!.resource?.blogger!
            }
            if recommendations[indexx].article!.resource != nil && recommendations[indexx].article!.resource?.blogger_image_url != nil{
                cell.get_blogger_image(url: recommendations[indexx].article!.resource!.blogger_image_url!)
            }
            if recommendations[indexx].article!.article_image_url != nil{
                
                cell.get_article_image(url: recommendations[indexx].article!.article_image_url!)
                cell.articleImageView.backgroundColor = UIColor.clear
            }
            if recommendations[indexx].article!.article_date != nil{
                let date = recommendations[indexx].article!.article_date!
                
                cell.dateLabel.text = date.dashedStringFromDate()
            }
            
            
            
            if cell.l_article != nil{
                if cell.l_article!.set_likes == false {
                    // load cell here
                    cell.likeCountLabel.text = ""
                    cell.likeButton.isSelected = false
                }else{
                    // set like count label and heartbutton
                    if cell.l_article!.likes == nil{
                        cell.likeCountLabel.text = ""
                    }else{
                        let x = cell.l_article!.title!.numberOfVowels + cell.l_article!.likes
                        cell.likeCountLabel.text = " \(x)"//" \(count)"
                        //                        cell.likeCountLabel.text = "\(cell.l_article!.likes)"
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
            
           
            
            return cell
        }else if recommendations.count > indexx && recommendations[indexx].video != nil{
            let cell: VideoCell = tableview.dequeueReusableCell(withIdentifier: "VideoCellVideo", for: indexPath) as! VideoCell
            print("Showing video cell")
            // title
            if recommendations[indexx].video!.title != nil{
                cell.titleLabel.text = recommendations[indexx].video!.title!
            }
            // video image
            if recommendations[indexx].video!.video_image_url != nil{
                cell.get_video_image(url: recommendations[indexx].video!.video_image_url!)
            }
            
            // shadow
            //            cell.borderView.layer.shadowColor = UIColor.black.cgColor
            //            cell.borderView.layer.shadowOpacity = 0.6
            //            cell.borderView.layer.shadowOffset = CGSize(width: 0, height: 0.7)
            //            cell.borderView.layer.shadowRadius = 1.2
            
            tableView.estimatedRowHeight = 275
            
            return cell
        }else{// if recommendations.count > 0 && recommendations[indexx].product != nil{
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
            return 155//90//322 //shrinking for a better look (sometimes less is more)
        }else if recommendations.count > indexx && recommendations[indexx].product != nil{
            return 92
        }else if recommendations.count > indexx && recommendations[indexx].video != nil{
            return 275 //UITableViewAutomaticDimension // 275
        }else{// if recommendations.count > 0 && recommendations[indexx].product != nil{
            //Article
            return 595//UITableViewAutomaticDimension
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var indexx = indexPath.row - 1
        if indexPath.row == 0{
            //Header Cell, do nothing
        }else if recommendations[indexx].product != nil{
            //            self.display_product()
        }else if recommendations[indexx].article != nil{
            // visit article url
            self.selected_article = recommendations[indexx].article!
            if recommendations[indexx].article!.article_url != nil{
                self.segue_to_article()
            }else{
                print("ITS NIL")
            }
        }else if recommendations[indexx].video != nil && recommendations[indexx].video!.video_url != nil{
            //load this video in this vc
            self.current_video = recommendations[indexx].video!
            self.url_string = recommendations[indexx].video!.video_url!
            self.create_youtube_video()
            self.tableview.reloadData()
        }
        tableview.deselectRow(at: indexPath, animated: true)
        
    }

    
    // ArticleDelegate
    func update_article_cell(article : Article){
        // find this article in the array (by id), then update the article
        
        article.set_likes = true
        var searchable = Searchable()
        searchable.article = article
        //            results[index].article = article
        self.tableview.reloadData()
     
    }
    func view_channel(channel_id: Int){
        print("I am the channel silly")
    }


    
    func visit_this_channel(){
        // visit the channel that is displaying the video
        if current_video!.resource!.id != nil{
            self.selected_channel = current_video!.resource!.id!
            self.segue_to_channel()
        }
    }
    
    func segue_to_channel(){
        performSegue(withIdentifier: "video to channel", sender: self)
    }
    
    
    func create_youtube_video(){
        var frame = CGRect(x: -20, y: 10, width: self.view.frame.width + 20, height: self.view.frame.width * (9.0/16.0))

//        view.addSubview(videoPlayer)
//        videoPlayer.snp.makeConstraints { (make) in
//            make.top.equalTo(self.view).offset(20)
//            make.left.right.equalTo(self.view)
////            // Note here, the aspect ratio 16:9 priority is lower than 1000 on the line, because the 4S iPhone aspect ratio is not 16:9
//            make.height.equalTo(videoPlayer.snp.width).multipliedBy(9.0/16.0).priority(750)
//        }

        if url_string != nil{
            print("Loading Video")
            url = URL(string: url_string!)
            videoPlayer.loadVideoURL(url!)
        }


    }
    
    
    func share_article(){
        print("Displaying UIActivity Controller")
        let textToShare = "\(self.current_video!.title!)\n"
        
        if let myWebsite = NSURL(string: "\(self.current_video!.video_url!)") {
            let objectsToShare = [myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            //
            
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }

    
    
    // Likes
    
    func change_button(){
        if current_video != nil{
            if self.current_video!.user_like == false {
                // change back to red heart icon
                self.current_video!.user_like = true
                self.like_animation()
                //                likeButton.setImage(UIImage(named: "red heart icon"), for: .normal)
            }else{
                self.current_video!.user_like = false
                self.unlike_animation()
                //                likeButton.setImage(UIImage(named: "selected heart icon"), for: .normal)
            }
        }
    }
    
    func like_animation(){
        
        UIView.animate(withDuration: 0.15) {
            self.likeButton.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        }
        var delayInSeconds = 0.15
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            UIView.animate(withDuration: 0.15) {
                self.likeButton.setImage(UIImage(named: "selected heart icon"), for: .normal)
                self.likeButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }
    
    func unlike_animation(){
        
        UIView.animate(withDuration: 0.15) {
            self.likeButton.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        }
        var delayInSeconds = 0.15
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            UIView.animate(withDuration: 0.15) {
                self.likeButton.setImage(UIImage(named: "red heart icon"), for: .normal)
                self.likeButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }
    
    func like_video(){
        
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!,
                "uarticle" : current_video!.id!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/articles/like_an_article", method: .post, parameters: parameters).responseJSON { (response) in
                if let count = response.result.value as? Int{
                    if count != nil{//0{
                        let x = self.current_video!.title!.numberOfVowels + count
                        self.likeCountLabel.text = " \(x)"//" \(count)"
                    }else{
                        let x = self.current_video!.title!.numberOfVowels
                        self.likeCountLabel.text = " \(x)"//" \(count)"
                    }
                    print(response.result.value)
                }
            }
        }
        
    }
    
    func get_video_likes(){
        
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "uarticle" : current_video!.id!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/articles/get_article_like_count", method: .post, parameters: parameters).responseJSON { (response) in
                if let count = response.result.value as? Int{
                    if count != nil{//0{
                        let x = self.current_video!.title!.numberOfVowels + count
                        self.likeCountLabel.text = " \(x)"//" \(count)"
                    }else{
                        let x = self.current_video!.title!.numberOfVowels
                        self.likeCountLabel.text = " \(x)"//" \(count)"
                    }

                    print(response.result.value)
                }
            }
        }
        
    }
    
    func did_user_like_video(){
        print("starting did_user_like_article")
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!,
                "uarticle" : current_video!.id!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/users/did_user_like_article", method: .post, parameters: parameters).responseJSON { (response) in
                print("Result: \(response.result.value)")
                if let result = response.result.value as? Bool{
                    if result == true{
                        print("true, button state is now selected")
                        // user already liked this. Set button as selected
                        self.likeButton.setImage(UIImage(named: "selected heart icon"), for: .normal)
                        
                    }else{
                        print("false or nothing")
                        // user didn't like article, or error
                        self.likeButton.setImage(UIImage(named: "red heart icon"), for: .normal)
                        
                    }
                    print("done did_user_like_article")
                }
            }
        }
        
    }
    
    
    
    func get_recommendations(){
        self.recommendations.removeAll()
        print("Starting Handpicked_Query")
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/articles/recommended_articles", method: .post, parameters: parameters).responseJSON { (response) in
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
                                    result.video = v
                                    self.recommendations.append(result)
                                    
                                    
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
                                    result.article = a
                                    self.recommendations.append(result)

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
                            article.article!.did_user_like_article()
                        }
                        //                        if self.selected_handpicked == true{
                        //                            // shuffle the array
                        //                            self.results.shuffle()
                        //                        }else{
                        //                            // organize by dates
                        //
                        //                        }
                        
                        print("done -- get_topics")
                        self.tableview.reloadData()
                        
                    }
                    
                }else{
                    print("Resource.Article ERROR \(article.article!.id!)")
                    self.tableview.reloadData()
                }
            }
        }
    }
    

    
    
    
//trash create_video TRASH
    func create_video(){
        player = BMPlayer()
        view.addSubview(player)
        player.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(20)
            make.left.right.equalTo(self.view)
            // Note here, the aspect ratio 16:9 priority is lower than 1000 on the line, because the 4S iPhone aspect ratio is not 16:9
            make.height.equalTo(player.snp.width).multipliedBy(9.0/16.0).priority(750)
        }
        // Back button event
        player.backBlock = { (true) in
            let _ = self.navigationController?.popViewController(animated: true)
        }
        //https://www.youtube.com/watch?v=cnAUnGjMd5U
        //http://baobab.wdjcdn.com/14525705791193.mp4
        let asset = BMPlayerResource(url: URL(string: "https://www.youtube.com/watch?v=cnAUnGjMd5U")!,
                                     name: "风格互换：原来你我相爱")
        player.setVideo(resource: asset)
    }
    
    
    func nav_back() -> Bool{
        let _ = self.navigationController?.popViewController(animated: true)
        return true
    }
    
    func set_backward_navigation(){
        if action == "profile"{
            // came from profile View Controller, unwind using unwind_proVC_button
            self.backButton.addTarget(self, action: #selector(VideoViewController.unwind_profile), for: .touchUpInside)
        }else if action == "channel"{
            self.backButton.addTarget(self, action: #selector(VideoViewController.unwind_channel), for: .touchUpInside)

        }else{
            // came from home tab
            self.backButton.addTarget(self, action: #selector(VideoViewController.unwind_home), for: .touchUpInside)
        }
        
        self.likeButton.setTitle("", for: .normal)
        self.likeButton.isSelected = false
        if self.current_video != nil{
            self.likeButton.addTarget(self, action: #selector(VideoViewController.like_video), for: .touchUpInside)
            self.likeButton.addTarget(self, action: #selector(VideoViewController.change_button), for: .touchUpInside)
        }

        
    }
    
    
    
    func track_reading(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    
    func updateCounting(){
        self.reading_time += 1
        print("Updated Reading Time: \(self.reading_time)")
    }
    
    func send_reading_time(){
        // send time to timer
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!,
                "uarticle" : current_video!.id!,
                "utimer" : self.reading_time
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/users/add_reading_time", method: .post, parameters: parameters).responseJSON { (response) in
                if let result = response.result.value as? String{
                    print(result)
                }
            }
        }
        // Stop Timer
        timer.invalidate()
        
    }

    
    func unwind_home(){
        unwind_homeVC_button.sendActions(for: .touchUpInside)
    }
    
    func unwind_profile(){
        unwind_proVC_button.sendActions(for: .touchUpInside)
    }

    func unwind_channel(){
        unwind_channelVC_button.sendActions(for: .touchUpInside)
    }
    
    func segue_to_article(){
        self.performSegue(withIdentifier: "video_to_article", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "video to channel"{
            let vvc : UINavigationController = segue.destination as! UINavigationController
            let vc : ChannelViewController = vvc.childViewControllers.first as! ChannelViewController
            vc.channel_id = self.selected_channel!
            vc.action = "video"
            
        }
        if segue.identifier == "video_to_article"{
            let vc : ArticleViewController = segue.destination as! ArticleViewController
            vc.article_url = self.selected_article!.article_url!
            vc.article = self.selected_article
            vc.action = "video"
        }
    }
    

}
