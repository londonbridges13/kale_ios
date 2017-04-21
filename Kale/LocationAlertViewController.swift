//
//  LocationAlertViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 12/1/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit

class LocationAlertViewController: UIViewController {

    @IBOutlet var okayButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        okayButton.layer.cornerRadius = 6
        okayButton.addTarget(self, action: #selector(LocationAlertViewController.ask_for_location), for: .touchUpInside)
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ask_for_location(){
        // Display System alert asking for location
        print("Asking for location")
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
