//
//  PlayerViewController.swift
//  Kale
//
//  Created by Lyndon Samual McKay on 5/10/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import YouTubePlayer

class PlayerViewController: UIViewController {

    var videoPlayer: YouTubePlayerView!
    var url : URL?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func create_youtube_video(){
        var frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)

        videoPlayer = YouTubePlayerView(frame: frame)
        view.addSubview(videoPlayer)
        
        
        videoPlayer.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(20)
            make.left.right.equalTo(self.view)
            // Note here, the aspect ratio 16:9 priority is lower than 1000 on the line, because the 4S iPhone aspect ratio is not 16:9
            make.height.equalTo(videoPlayer.snp.width).multipliedBy(9.0/16.0).priority(750)
        }
        
        if url != nil{
            self.videoPlayer.loadVideoURL(url!)
        }
        
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
