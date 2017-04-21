//
//  FeedbackViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 2/17/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import Jelly


class FeedbackViewController: UIViewController {

    @IBOutlet var loveButton : UIButton!
    @IBOutlet var likeButton : UIButton!
    @IBOutlet var mehButton : UIButton!
    @IBOutlet var hateButton : UIButton!
    @IBOutlet var badButton : UIButton!
    @IBOutlet var navButton : UIButton!
    @IBOutlet var backHomeButton : UIButton!
    @IBOutlet var backSettingButton : UIButton!

    @IBOutlet var questionLabel : UILabel!
    var jellyAnimator: JellyAnimator?
    var feedback : String?
    var from : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionLabel.text = "How do you feel about Undercooked?"
        loveButton.addTarget(self, action: #selector(FeedbackViewController.love_it), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(FeedbackViewController.like_it), for: .touchUpInside)
        mehButton.addTarget(self, action: #selector(FeedbackViewController.meh), for: .touchUpInside)
        badButton.addTarget(self, action: #selector(FeedbackViewController.bad), for: .touchUpInside)
        hateButton.addTarget(self, action: #selector(FeedbackViewController.hate_it), for: .touchUpInside)
        
        if from == "home"{
            navButton.addTarget(self, action: "go_back_home", for: .touchUpInside)
            navButton.alpha = 0 // remove the back button, the user must give feedback
        }else if from == "settings"{
            navButton.addTarget(self, action: "go_back_setting", for: .touchUpInside)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func love_it(){
        animate_button(button: loveButton)
        self.feedback = "Love It"
        self.ask_for_suggestions()
    }
    func like_it(){
        animate_button(button: likeButton)
        self.feedback = "Like It"
        self.ask_for_suggestions()
    }
    func meh(){
        animate_button(button: mehButton)
        self.feedback = "Meh"
        self.ask_for_suggestions()
    }
    func bad(){
        animate_button(button: badButton)
        self.feedback = "It's Bad"
        self.ask_for_suggestions()
    }
    func hate_it(){
        animate_button(button: hateButton)
        self.feedback = "Hate It"
        self.ask_for_suggestions()
    }
    
    
    func animate_button(button : UIButton){
        UIView.animate(withDuration: 0.1,
                       animations: {
                        button.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.1) {
                            button.transform = CGAffineTransform.identity
                        }
        })
    }
    
    
    
    func ask_for_suggestions(){
        // this presents an alert that will ask the user for suggestions
        var adelayInSeconds = 0.125
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + adelayInSeconds) {
            let viewController : SuggestionAlertViewController = self.storyboard?.instantiateViewController(withIdentifier: "SuggestionAlertViewController") as! SuggestionAlertViewController
            viewController.feedback = self.feedback!
            let midy = 25 //(self.view.frame.height / 2) - (225 / 2)
            let alertPresentation = JellySlideInPresentation(dismissCurve: .linear,
                                                             presentationCurve: .linear,
                                                             cornerRadius: 2,
                                                             backgroundStyle: .blur(effectStyle: .dark),
                                                             jellyness: .jellier,
                                                             duration: .normal,
                                                             directionShow: .top,
                                                             directionDismiss: .top,
                                                             widthForViewController: .custom(value:self.view.frame.width - 10),
                                                             heightForViewController: .custom(value:225),
                                                             horizontalAlignment: .center,
                                                             verticalAlignment: .top,
                                                             marginGuards: UIEdgeInsets(top: CGFloat(midy), left: 5, bottom: 30, right: 5))
            
            
            let presentation = alertPresentation
            self.jellyAnimator = JellyAnimator(presentation:presentation)
            self.jellyAnimator?.prepare(viewController: viewController)
            self.present(viewController, animated: true, completion: nil)
            
            viewController.okayButton.addTarget(self, action: #selector(FeedbackViewController.dismiss_vc), for: .touchUpInside)
        }
    }
    
    func dismiss_vc(){
        // dismiss the FeedbackViewController
        self.dismiss(animated: true, completion: nil)
    }
    
    

    func go_back_home(){
        backHomeButton.sendActions(for: .touchUpInside)
    }
    
    func go_back_setting(){
        backSettingButton.sendActions(for: .touchUpInside)
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
