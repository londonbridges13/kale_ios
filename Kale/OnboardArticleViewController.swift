//
//  OnboardWebViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 11/29/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit

class OnboardArticleViewController: UIViewController {

    @IBOutlet var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.nextButton.layer.cornerRadius = 4
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
      
    }
    

}
