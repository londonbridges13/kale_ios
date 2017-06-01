//
//  ChannelViewController.swift
//  Kale
//
//  Created by Lyndon Samual McKay on 5/17/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import SnapKit
import YouTubePlayer
import Alamofire
import RealmSwift

class ChannelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ArtcleCellDelegate {

    @IBOutlet var tableview: UITableView!
    @IBOutlet var subscribeButton : UIButton!
    @IBOutlet var unwindToVideoVCButton : UIButton!
    @IBOutlet var unwindToHomeVCButton : UIButton!
    @IBOutlet var backButton : UIButton!
    @IBOutlet var titleLabel : UILabel!

    var channel_id : Int?
    var resource : Resource?
    var channel : String?
    var articles = [Article]()
    var videos = [Video]()
    var results = [Searchable]() // All Results, Products, Articles, Ads, Promotions
    var topic_viewed = "Handpicked"
    var selected_article_url : String?
    var selected_article : Article?
    var selected_video: Video?
    var loadedHomeVC = false
    var loaded_all_cells = false
    var isNewDataLoading = true
    var pagination = 1
    var action = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        self.backButton.addTarget(self, action: "go_back", for: .touchUpInside)
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        self.get_channel_info()
        self.get_channel_articles()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func unwind_to_ChannelVC(segue : UIStoryboardSegue){
        
    }
    
    func go_back(){
        if action != ""{
            if action == "home"{
                print("unwinding home")
                self.unwindToHomeVCButton.sendActions(for: .touchUpInside)
            }else if action == "video"{
                print("unwinding video")
                self.unwindToVideoVCButton.sendActions(for: .touchUpInside)
            }else if action == "somewhere else"{
                
            }
        }
    }
    
    
    //tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count + 2 // For header cell and loading cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var indexx = indexPath.row - 1
        if indexPath.row == 0{
            let cell : ChannelDescriptionCell = tableview.dequeueReusableCell(withIdentifier: "ChannelDescriptionCell", for: indexPath) as! ChannelDescriptionCell
            
            cell.fake_count = self.titleLabel.text!.characters.count

            if self.resource != nil{
                cell.count_posts(id: self.resource!.id!)
                cell.count_subscribers(id: self.resource!.id!)
                cell.is_subscribed(id: self.resource!.id!)
                cell.get_description(id: self.resource!.id!)
            }else if self.channel_id != nil{
                print("doing channel id")
                cell.count_posts(id: self.channel_id!)
                cell.count_subscribers(id: self.channel_id!)
                cell.is_subscribed(id: self.channel_id!)
                cell.get_description(id: self.channel_id!)
            }
            if self.resource != nil{
                cell.get_channel_image(url: self.resource!.blogger_image_url!)
            }
            tableview.estimatedRowHeight = 176
            return cell
        }else if indexPath.row > results.count{
            //LoadingCell
            let cell : LoadingCell = tableview.dequeueReusableCell(withIdentifier: "LoadingCellChannel", for: indexPath) as! LoadingCell
            
            
            if !isNewDataLoading{
                isNewDataLoading = true
                pagination += 1
                continue_channel_articles()
                
            }
            
            
            if loaded_all_cells == true{
                // display "All Done" label
                
            }
            
            
            
            return cell
        }else if results.count > indexx && results[indexx].article != nil{
            // Display articles
            let cell: V2ArticleCell = tableview.dequeueReusableCell(withIdentifier: "V2ArticleCellChannel", for: indexPath) as! V2ArticleCell
            
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
            }
            if results[indexx].article!.resource != nil && results[indexx].article!.resource?.blogger_image_url != nil{
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
            
            if results.count == indexPath.row{
                isNewDataLoading = false
                print("isNewDataLoading = false")
            }
            
            return cell
        }else if results.count > indexx && results[indexx].video != nil{
            let cell: VideoCell = tableview.dequeueReusableCell(withIdentifier: "VideoCellChannel", for: indexPath) as! VideoCell
            print("Showing video cell")
            // title
            if results[indexx].video!.title != nil{
                cell.titleLabel.text = results[indexx].video!.title!
            }
            // video image
            if results[indexx].video!.video_image_url != nil{
                cell.get_video_image(url: results[indexx].video!.video_image_url!)
            }
            
            
            tableView.estimatedRowHeight = 275
            
            if results.count == indexPath.row{
                isNewDataLoading = false
                print("isNewDataLoading = false")
            }
            
            return cell
        }else{ //if results.count > indexx && results[indexx].product != nil{
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
            return UITableViewAutomaticDimension//90//322 //shrinking for a better look (sometimes less is more)
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
//            self.display_product()
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
    

    func get_channel_info(){
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "uchannel": channel_id!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/resources/get_channel_info", method: .post, parameters: parameters).responseJSON { (response) in
                //                print(response.result.value!)
                if response.result.value != nil{
                    
                    if let resource = response.result.value as? NSDictionary{
                        // Inside Resource
                        var r = Resource()
                        var title = resource["title"] as? String?
                        if title != nil{
                            r.blogger = title!
                            self.titleLabel.text = title!
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
                        
                        self.resource = r
                        
                        print(r)
                        
                        
                        print("done -- get_topics")
                        self.tableview.reloadData()
                    }
                    
                }else{
                    self.tableview.reloadData()
                }
            }
        }
    }
    
    
    func get_channel_articles(){
        pagination = 1
        loaded_all_cells = false
        self.results.removeAll()
        
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "uchannel": channel_id!,
                "page": pagination
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/resources/display_resource_articles", method: .post, parameters: parameters).responseJSON { (response) in
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
                                    
                                    self.results.append(result)
                                    //                            print(a.desc)
                                    //                            print("\(self.results.count)")
                                    self.get_article_resource(article: result)
                                    //                            self.tableview.reloadData()
                                }
                            }
                            self.tableview.reloadData()
                            print("first results === \(self.results.count)")

                        }
                    }
                }
            }
        }
    }
    
    
    func continue_channel_articles(){
        //        self.results.removeAll()
        
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "uchannel": channel_id!,
                "page": pagination
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/resources/display_resource_articles", method: .post, parameters: parameters).responseJSON { (response) in
                if let articles = response.result.value as? NSArray{
                    print(response.result.value)
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
                                    self.results.append(result)

                                    
                                    //                            self.results.append(result)
                                    //                            print(a.desc)
                                    //                            print("\(self.results.count)")
                                    self.get_article_resource(article: result)
                                    //                            self.tableview.reloadData()
                                }
                            }
                            
                            self.tableview.reloadData()
                            print("continued results === \(self.results.count)")
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
                            print("Hey channel url: \(image_url!)")
                        }
                        
                        var id = resource["id"] as? Int
                        if id != nil{
                            r.id = id!
                        }
                        
                        article.article?.resource = r // already grabs image url
                        article.video?.resource = r // already grabs image url
                        
                        if article.article != nil{
                            self.did_user_like_article(article: article.article!)
                        }
                        
                        print(r)
                        
                        
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

        article.set_likes = true
        var searchable = Searchable()
        searchable.article = article
        //            results[index].article = article
        self.tableview.reloadData()
        //        }else{
        //            print("Didn't find index")
        //        }
    }
    
    
    // View Channel
    func view_channel(channel_id: Int){
        print("I am the channel silly")
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
    

    
    
    
    func segue_to_video(){
        print("seguing")
        performSegue(withIdentifier: "channel_to_video", sender: self)
    }
    
    func visit_article(url : String){
        self.selected_article_url = url
        
        segue_to_article()
    }
    
    func segue_to_article(){
        self.performSegue(withIdentifier: "channel_to_article", sender: self)
    }
    


    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "channel_to_article"{
            let vc : ArticleViewController = segue.destination as! ArticleViewController
            vc.article_url = selected_article_url!
            vc.article = self.selected_article
            vc.action = "channel"
        }
        if segue.identifier == "channel_to_video"{
            let vc : VideoViewController = segue.destination as! VideoViewController
            vc.url_string = selected_article_url!
            vc.current_video = self.selected_video!
            vc.action = "channel"
        }


        
    }
    

}
