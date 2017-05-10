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

class VideoViewController: UIViewController {

    var player: BMPlayer!
    var videoPlayer: YouTubePlayerView!
    var url : URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        create_youtube_video()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func create_youtube_video(){
        var frame = CGRect(x: -20, y: 10, width: self.view.frame.width + 20, height: self.view.frame.width * (9.0/16.0))

        videoPlayer = YouTubePlayerView(frame: frame)
        view.addSubview(videoPlayer)
        url = URL(string: "https://www.youtube.com/watch?v=9qn5oAN__2w")
//        videoPlayer.snp.makeConstraints { (make) in
//            make.top.equalTo(self.view).offset(20)
//            make.left.right.equalTo(self.view)
////            // Note here, the aspect ratio 16:9 priority is lower than 1000 on the line, because the 4S iPhone aspect ratio is not 16:9
//            make.height.equalTo(videoPlayer.snp.width).multipliedBy(9.0/16.0).priority(750)
//        }

        videoPlayer.loadVideoURL(url!)


    }

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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
