//
//  OnboardResourceViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 11/30/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit

class OnboardResourceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var nextButton: UIButton!
    @IBOutlet var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.nextButton.layer.cornerRadius = 4
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    //tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : OnboardResourceTableViewCell = tableView.dequeueReusableCell(withIdentifier: "OnboardResourceTableViewCell", for: indexPath) as! OnboardResourceTableViewCell
        
//        cell.resourceImageView.image = 
        cell.resourceLabel.text = "TasteMade"
        return cell
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
