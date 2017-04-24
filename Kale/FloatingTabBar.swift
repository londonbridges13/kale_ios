//
//  FloatingTabBar.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 4/8/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import UIKit

class FloatingTabBar: UIView {

    
    var view : UIView!
    
    
    @IBOutlet var homeButton: UIButton!
    @IBOutlet var profileButton: UIButton!
    
    
    
    
    func fadeAway(){
        view.fadeOut(duration: 0.3)
        var delayInSeconds = 0.25
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            
            self.view.alpha = 0
            self.removeFromSuperview()
            self.view.removeFromSuperview()
        }
    }
    
    
    
    
    
    func xibSetup() {
        view = loadViewFromNib()
        
        
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        
        // Make the view stretch with containing view
        view.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(UIViewAutoresizing.flexibleHeight)
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return nibView
    }
    
    
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    

}
