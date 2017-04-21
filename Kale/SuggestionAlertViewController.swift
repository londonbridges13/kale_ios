//
//  SuggestionAlertViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 2/17/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import Jelly

class SuggestionAlertViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var textView : UITextView!
    @IBOutlet var okayButton : UIButton!
    
    var feedback : String?
    var suggestion : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = ""
        okayButton.setTitle("Done", for: .normal)
        addDoneButtonOnKeyboard()
        textView.delegate = self
        okayButton.layer.cornerRadius = 5
        var adelayInSeconds = 0.125
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + adelayInSeconds) {
            self.textView.becomeFirstResponder()
        }
        self.okayButton.addTarget(self, action: #selector(SuggestionAlertViewController.done), for: .touchUpInside)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func addDoneButtonOnKeyboard()
    {
        var doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        
        var flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        var done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(SuggestionAlertViewController.done_2))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.textView.inputAccessoryView = doneToolbar
    }

    func done_2(){
        // this sends actions from the okayButton so the the FeedbackViewController closes aswell
        self.okayButton.sendActions(for: .touchUpInside)
    }
    
    func done(){
        // send suggestion, then dismiss vc
        if self.textView.text != ""{
            // send suggestion through Almafire
            self.suggestion = self.textView.text
            print(self.textView.text)
        }else{
            self.suggestion = "No Suggestions"
        }
        self.send_feedback()
        self.dismiss_vc()
    }
    
    
    func send_feedback(){
        // send feedback and suggestion 
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!,
                "suggestion" : self.suggestion!,
                "feedback" : self.feedback!
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/feedbacks/feedback", method: .post, parameters: parameters).responseJSON { (response) in
                
            }
        }

    }
    
    func dismiss_vc(){
        self.dismiss(animated: true, completion: nil)
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
