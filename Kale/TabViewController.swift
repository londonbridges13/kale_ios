//
//  TabViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 12/1/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {

    @IBOutlet var tab: UITabBar!
    
    let pop_red = UIColor(colorLiteralRed: 255/255, green: 103/255, blue: 102/255, alpha: 1)
    let pop_blue = UIColor(colorLiteralRed: 29/255, green: 171/255, blue: 192/255, alpha: 1)
    let pop_orange = UIColor(colorLiteralRed: 255/255, green: 126/255, blue: 85/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let tab = UITabBar()
//        self.viewControllers?[0].tabBarItem.selectedImage = UIImage(named: "u icon (blue)")
//        tab.items?[0].setTitleTextAttributes([NSForegroundColorAttributeName: pop_blue], for:.selected)
//        tab.items?[1].setTitleTextAttributes([NSForegroundColorAttributeName: pop_red], for:.selected)
//        tab.items?[2].setTitleTextAttributes([NSForegroundColorAttributeName: pop_orange], for:.selected)

        if let items = self.tabBar.items {
            let tabBarImages = [UIImage(named: "u icon (blue)"),UIImage(named: "ProfileIcon"),UIImage(named: "ExploreIcon")] // tabBarImages: [UIImage]
            for i in 0..<items.count {
                let tabBarItem = items[i]
                let tabBarImage = tabBarImages[i]
//                tabBarItem.image = tabBarImage?.withRenderingMode(.alwaysOriginal)
                tabBarItem.selectedImage = tabBarImage?.withRenderingMode(.alwaysOriginal)
                tabBarItem.image = tabBarImage
            }
        }

        
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
