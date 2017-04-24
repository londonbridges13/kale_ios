//
//  OnboardEventsViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 11/29/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import RAMPaperSwitch
import Jelly

class OnboardEventsViewController: UIViewController {

//    @IBOutlet var paperSwitch1: RAMPaperSwitch!
    @IBOutlet weak var bigLabel: UILabel!
    @IBOutlet weak var smallLabel: UILabel!
    @IBOutlet var yesButton: UIButton!
    @IBOutlet var noButton: UIButton!
    
    var orange = UIColor(red: 255.0/255.0, green: 126/255.0, blue: 85/255.0, alpha: 1)
    var jellyAnimator: JellyAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        yesButton.layer.cornerRadius = 4
        noButton.layer.cornerRadius = 4
        noButton.addTarget(self, action: #selector(OnboardEventsViewController.move_to_sign_in), for: .touchUpInside)
        yesButton.addTarget(self, action: #selector(OnboardEventsViewController.display_location_alert), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func move_to_sign_in(){
        self.performSegue(withIdentifier: "sign in", sender: self)
    }
    
    
    func display_location_alert(){
        //LocationAlertViewController
        let viewController : LocationAlertViewController = self.storyboard?.instantiateViewController(withIdentifier: "LocationAlertViewController") as! LocationAlertViewController
        
        let midy = (self.view.frame.height / 2) - (173 / 2)
        let alertPresentation = JellySlideInPresentation(dismissCurve: .linear,
                                                         presentationCurve: .linear,
                                                         cornerRadius: 2,
                                                         backgroundStyle: .blur(effectStyle: .dark),
                                                         jellyness: .jellier,
                                                         duration: .normal,
                                                         directionShow: .top,
                                                         directionDismiss: .top,
                                                         widthForViewController: .custom(value:self.view.frame.width - 10),
                                                         heightForViewController: .custom(value:173),
                                                         horizontalAlignment: .center,
                                                         verticalAlignment: .top,
                                                         marginGuards: UIEdgeInsets(top: midy, left: 5, bottom: 30, right: 5))
        
        
        let presentation = alertPresentation
        self.jellyAnimator = JellyAnimator(presentation:presentation)
        self.jellyAnimator?.prepare(viewController: viewController)
        self.present(viewController, animated: true, completion: nil)

    }
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "sign in"{
            let vc : SignUpInViewController = segue.destination as! SignUpInViewController
        }
        
    }
    

}
