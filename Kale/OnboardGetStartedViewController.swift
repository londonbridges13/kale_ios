//
//  OnboardGetStartedViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 11/30/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit

class OnboardGetStartedViewController: UIViewController {

    @IBOutlet var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.startButton.layer.cornerRadius = 6
        self.startButton.layer.borderColor = UIColor.gray.cgColor
        self.startButton.layer.borderWidth = 1.25

        self.navigationController?.setNavigationBarHidden(true, animated: true)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
