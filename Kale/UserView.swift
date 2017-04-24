//
//  UserView.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 4/7/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

class UserView: UIView {


    var view : UIView!
    
    
    @IBOutlet var profileButton: UIButton!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var profileLabel: UILabel!
    
    
    
    
    func fadeAway(){
        view.fadeOut(duration: 0.3)
        var delayInSeconds = 0.25
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            
            self.view.alpha = 0
            self.removeFromSuperview()
            self.view.removeFromSuperview()
        }
    }
    
    
    
    
    
    func xibSetup() {
        view = loadViewFromNib()
        
        
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        profileImage.layer.cornerRadius = 27
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        profileLabel.text = ""
        get_username()
        get_profile_pic()
        
        // Make the view stretch with containing view
        view.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(UIViewAutoresizing.flexibleHeight)
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return nibView
    }
   
    
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    

    
    
    
    // Loading the Image and UserName
    
    func get_username(){
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            // API Call for user profile pic, might not have one
            
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/users/profile", method: .post, parameters: parameters).responseJSON { (response) in
                //                print(response.result.value!)
                if let result = response.result.value as? NSDictionary{
                    var name = result["name"] as? String
                    if name != nil{
                        self.profileLabel.text = name!
                    }
                    print("done getting username")
                }
            }
        }
    }
    
    
    
    func get_profile_pic(){
        
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            // API Call for user profile pic, might not have one
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/users/profile_pic", method: .post, parameters: parameters).responseJSON { (response) in
                //                print(response.result.value!)
                if response.result.value != nil{
                    var profile_pic_url = "\(response.result.value!)" // changed for amazon
                    print(profile_pic_url)
                    self.download_image(image_url: profile_pic_url)
                    print("done")
                }
            }
        }
        
    }
    
    func download_image(image_url: String){
        // KingFisher download
        let url = URL(string: image_url)
        //        let image = UIImage(named: "default_profile_icon")
        self.profileImage.kf.setImage(with: url)//, placeholder: image)
    }

    


}
