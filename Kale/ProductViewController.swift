//
//  ProductViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 12/2/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit

class ProductViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var viewButton: UIButton!
    @IBOutlet var productImageView: UIImageView!

    var price : String?
    var product_title : String?
    var desc : String?
    var product_image : UIImage?
    var url : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
