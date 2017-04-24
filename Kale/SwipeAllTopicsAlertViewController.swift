//
//  SwipeAllTopicsAlertViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 3/14/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import UIKit

class SwipeAllTopicsAlertViewController: UIViewController {

    @IBOutlet var okayButton : UIButton!
    @IBOutlet var imagesView : UIView!
    @IBOutlet var finger : UIImageView!
    @IBOutlet var pull: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        okayButton.layer.cornerRadius = 5
        okayButton.addTarget(self, action: #selector(SwipeAllTopicsAlertViewController.dismissVC), for: .touchUpInside)
        let adelayInSeconds = 0.35
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + adelayInSeconds) {
            self.swiping_animation()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func swiping_animation(){
//        imagesView.slow_scroll()
//        finger.slight_scroll()
       
        UIView.animate(withDuration: 0.55) {
            self.finger.transform = CGAffineTransform(translationX: -80, y: 0)
        }
        
        UIView.animate(withDuration: 0.75) {
            self.imagesView.transform = CGAffineTransform(translationX: -250, y: 0)
        }
        
        
   
        
    }
    
    func dismissVC(){
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
extension UIView {
    func slow_scroll() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 1.75
        animation.values = [0,-350.0,0]
        layer.add(animation, forKey: "slow_scroll")
    }
}

extension UIView {
    func slight_scroll() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 1.5
        animation.values = [0, -65.0,0]
        layer.add(animation, forKey: "slight_scroll")
    }
}

