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

class VideoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

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
        }
        self.likeButton.addTarget(self, action: "like_video", for: .touchUpInside)
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
        var indexx = indexPath.row
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
            
            let cell : ArticleCell = tableview.dequeueReusableCell(withIdentifier: "ArticleCellInProduct", for: indexPath) as! ArticleCell
            if recommendations.count > 0 && recommendations[indexx].article != nil{
                if recommendations[indexx].article!.title != nil{
                    cell.titleLabel.text = recommendations[indexx].article!.title!
                }
                if recommendations[indexx].article!.desc != nil{
                    cell.descLabel.text = recommendations[indexx].article!.desc!
                }
                if recommendations[indexx].article!.resource_title != nil{
                    cell.resourceLabel.text = recommendations[indexx].article!.resource_title!
                }
                if recommendations[indexx].article!.article_image_url != nil{
                    cell.get_article_image(url: recommendations[indexx].article!.article_image_url!)
                    cell.articleImageView.backgroundColor = UIColor.clear
                }
                if recommendations[indexx].article!.article_date != nil{
                    let date = recommendations[indexx].article!.article_date!
                    
                    cell.dateLabel.text = date.dashedStringFromDate()
                }
                
                
            }
            cell.topicLabel.text = ""
            
            return cell
            
        }else if recommendations.count > indexx && recommendations[indexx].video != nil{
            let cell: VideoCell = tableview.dequeueReusableCell(withIdentifier: "VideoCellHome", for: indexPath) as! VideoCell
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
                    if count != 0{
                        self.likeCountLabel.text = " \(count)"
                    }else{
                        self.likeCountLabel.text = ""
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
                    if count != 0{
                        self.likeCountLabel.text = " \(count)"
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
    
    
//trash create_video
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

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "video to channel"{
            let vc : ChannelViewController = segue.destination as! ChannelViewController
            vc.channel_id = self.selected_channel!
            
        }
    }
    

}
