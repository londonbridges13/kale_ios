//
//  LoadingCell.swift
//  Kale
//
//  Created by Lyndon Samual McKay on 5/4/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LoadingCell: UITableViewCell {

    var actIndi : NVActivityIndicatorView?
    var width : Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width

        var size : CGFloat = 37
        var xxp = CGFloat(screenWidth) / 2 - (size / 2)
        var hp = 10//130 / 2 - ((size / 3) * 2)
        let frame = CGRect(x: xxp, y: CGFloat(hp), width: size, height: size)
        self.actIndi = NVActivityIndicatorView(frame: frame, type: .lineScale, color: UIColor.darkGray, padding: 3)
        self.actIndi!.startAnimating()
        self.actIndi!.alpha = 0
        self.addSubview(self.actIndi!)
        self.actIndi!.fadeIn(duration: 0.2)
        self.actIndi!.startAnimating()
//        let adelayInSeconds = 20.25
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + adelayInSeconds) {
//            self.actIndi!.fadeOut()
//        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func load_cell(){
        var size : CGFloat = 37
        var xxp = CGFloat(width!) / 2 - (size / 2)
        var hp = 10//130 / 2 - ((size / 3) * 2)
        let frame = CGRect(x: xxp, y: CGFloat(hp), width: size, height: size)
        self.actIndi = NVActivityIndicatorView(frame: frame, type: .lineScale, color: UIColor.darkGray, padding: 3)
        self.actIndi?.startAnimating()
        self.actIndi?.alpha = 0
        self.addSubview(self.actIndi!)
        self.actIndi?.fadeIn(duration: 0.2)
        self.actIndi!.startAnimating()

    }
}
