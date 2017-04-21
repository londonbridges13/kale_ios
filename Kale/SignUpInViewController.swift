//
//  SignUpInViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 11/30/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Jelly
//import AlertOnboarding

class SignUpInViewController: UIViewController, AlertOnboardingDelegate {

    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var backgroundImageView: UIImageView!
    
    var jellyAnimator: JellyAnimator?
    var alertView: AlertOnboarding!

    var arrayOfImage = ["welcome","onboard1", "onboard2", "Go"]
    var arrayOfTitle = ["Welcome to Undercooked","Select Your Favorite Topics", "Read Interesting Articles", "Get Started"]
    var arrayOfDescription = ["Read the best articles on food.","We have a wide range of topics to choose from. \n Sweets, Vegan, Health and Nutrition, and more","Enjoy Stories, Gather Recipes, Share the fun","Sign Up and Get Started in Seconds!"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        applyMotionEffect(toView: backgroundImageView, magnitude: 30)

        self.signInButton.layer.cornerRadius = 4
        self.signUpButton.layer.cornerRadius = 4
        self.signInButton.layer.borderColor = UIColor.white.cgColor
        self.signUpButton.layer.borderColor = UIColor.white.cgColor
        self.signUpButton.layer.borderWidth = 1.25
        self.signInButton.layer.borderWidth = 1.25
        
        self.signUpButton.addTarget(self, action: "sign_up", for: .touchUpInside)
        self.signInButton.addTarget(self, action: "sign_in", for: .touchUpInside)

        
        var adelayInSeconds = 0.425
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + adelayInSeconds) {
            self.show_onboard_alert()
        }

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alertView = AlertOnboarding(arrayOfImage: arrayOfImage, arrayOfTitle: arrayOfTitle, arrayOfDescription: arrayOfDescription)
        alertView.delegate = self
    }
    override var prefersStatusBarHidden : Bool {
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func slideshow(){
        self.backgroundImageView.animationImages = [UIImage(named:"welcome")!, UIImage(named:"onboard1")!, UIImage(named:"onboard2")!]
        self.backgroundImageView.animationDuration = 1.0
        self.backgroundImageView.animationRepeatCount = 5
        self.backgroundImageView.startAnimating()

    }
    
    func show_onboard_alert(){
        self.alertView.show()
    }
    
  
    func sign_up(){
        //Jelly Animation required
        var signtext = "Sign Up"
        let viewController : SignUpInAlertViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpInAlertViewController") as! SignUpInAlertViewController
        viewController.labeltext = signtext
        viewController.segueTopicsButton.addTarget(self, action: #selector(SignUpInViewController.segue_to_select_topics), for: .touchUpInside)
        viewController.segueHomeButton.addTarget(self, action: #selector(SignUpInViewController.segue_to_home_tab), for: .touchUpInside)
        

        var midy = (self.view.frame.height / 2) - (240 / 2)
        let alertPresentation = JellySlideInPresentation(dismissCurve: .linear,
                                                         presentationCurve: .linear,
                                                         cornerRadius: 8,
                                                         backgroundStyle: .blur(effectStyle: .dark),
                                                         jellyness: .jellier,
                                                         duration: .normal,
                                                         directionShow: .top,
                                                         directionDismiss: .top,
                                                         widthForViewController: .custom(value:309),
            heightForViewController: .custom(value:240),
            horizontalAlignment: .center,
            verticalAlignment: .top,
            marginGuards: UIEdgeInsets(top: midy, left: 5, bottom: 30, right: 5))
        
        
        let presentation = alertPresentation
        self.jellyAnimator = JellyAnimator(presentation:presentation)
        self.jellyAnimator?.prepare(viewController: viewController)
        self.present(viewController, animated: true, completion: nil)
        

    }
    
    func sign_in(){
        //Jelly Animation required
        var signtext = "Sign In"
        let viewController : SignUpInAlertViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpInAlertViewController") as! SignUpInAlertViewController
        
        viewController.labeltext = signtext
        viewController.segueTopicsButton.addTarget(self, action: #selector(SignUpInViewController.segue_to_select_topics), for: .touchUpInside)
        viewController.segueHomeButton.addTarget(self, action: #selector(SignUpInViewController.segue_to_home_tab), for: .touchUpInside)

        var midy = (self.view.frame.height / 2) - (240 / 2)
        let alertPresentation = JellySlideInPresentation(dismissCurve: .linear,
                                                         presentationCurve: .linear,
                                                         cornerRadius: 8,
                                                         backgroundStyle: .blur(effectStyle: .dark),
                                                         jellyness: .jellier,
                                                         duration: .normal,
                                                         directionShow: .top,
                                                         directionDismiss: .top,
                                                         widthForViewController: .custom(value:309),
                                                         heightForViewController: .custom(value:240),
                                                         horizontalAlignment: .center,
                                                         verticalAlignment: .top,
                                                         marginGuards: UIEdgeInsets(top: midy, left: 5, bottom: 30, right: 5))
        
        
        let presentation = alertPresentation
        self.jellyAnimator = JellyAnimator(presentation:presentation)
        self.jellyAnimator?.prepare(viewController: viewController)
        self.present(viewController, animated: true, completion: nil)
        

    }
    
    
    func segue_to_home_tab(){
        self.performSegue(withIdentifier: "to home tab", sender: self)
    }

    func segue_to_select_topics(){
        self.performSegue(withIdentifier: "select topics", sender: self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    //--------------------------------------------------------
    // MARK: DELEGATE METHODS --------------------------------
    //--------------------------------------------------------
    
    func alertOnboardingSkipped(_ currentStep: Int, maxStep: Int) {
        print("Onboarding skipped the \(currentStep) step and the max step he saw was the number \(maxStep)")
    }
    
    func alertOnboardingCompleted() {
        print("Onboarding completed!")
    }
    
    func alertOnboardingNext(_ nextStep: Int) {
        print("Next step triggered! \(nextStep)")
    }
    
    
    
    // Motion
    func applyMotionEffect (toView view:UIView, magnitude:Float) {
        let xMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = -magnitude
        xMotion.maximumRelativeValue = magnitude
        
        let yMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        yMotion.minimumRelativeValue = -magnitude
        yMotion.maximumRelativeValue = magnitude
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [xMotion, yMotion]
        
        view.addMotionEffect(group)
    }
    

}
