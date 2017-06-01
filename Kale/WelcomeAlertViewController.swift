//
//  WelcomeAlertViewController.swift
//  Kale
//
//  Created by Lyndon Samual McKay on 5/25/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import UIKit

class WelcomeAlertViewController: UIViewController {

    @IBOutlet var doneButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        doneButton.layer.cornerRadius = 5
        doneButton.addTarget(self, action: #selector(WelcomeAlertViewController.dismissVC), for: .touchUpInside)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
