//
//  CustomSegue.swift
//  CustomSegues
//
//  Created by William Archimede on 16/09/2014.
//  Copyright (c) 2014 HoodBrains. All rights reserved.
//

import UIKit
import QuartzCore

enum CustomSegueAnimation {
    case Push
    case SwipeDown
    case GrowScale
    case CornerRotate
}

// MARK: Segue class
class CustomSegue: UIStoryboardSegue {
    
    var animationType = CustomSegueAnimation.Push
    
    override func perform() {
        switch animationType {
        case .Push:
            animatePush()
        case .SwipeDown:
            animateSwipeDown()
        case .GrowScale:
            animateGrowScale()
        case .CornerRotate:
            animateCornerRotate()
        }
    }
    func display_tab_bar(view : UIView){
        
        let alert = FloatingTabBar()
        let xpp = 15//self.view.frame.width / 2 - (self.view.frame.width - 30 / 2)
        alert.frame = CGRect(x: CGFloat(xpp), y: view.frame.height - 60, width: view.frame.width - 30 , height: 55)
        alert.layer.shadowColor = UIColor.black.cgColor
        alert.layer.shadowOpacity = 0.6
        alert.layer.shadowOffset = CGSize(width: 1, height: 1.3)
        alert.layer.shadowRadius = 2
        view.addSubview(alert)

    }
    public func showOverlay() {
        if  let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let window = appDelegate.window {
            
            let alert = FloatingTabBar()
            let xpp = 15//self.view.frame.width / 2 - (self.view.frame.width - 30 / 2)
            alert.frame = CGRect(x: CGFloat(xpp), y: window.frame.height - 60, width: window.frame.width - 30 , height: 55)
            alert.layer.shadowColor = UIColor.black.cgColor
            alert.layer.shadowOpacity = 0.6
            alert.layer.shadowOffset = CGSize(width: 1, height: 1.3)
            alert.layer.shadowRadius = 2
            window.addSubview(alert)
            
        }
    }

    private func animatePush() {
        let toViewController = destination
        let fromViewController = source
        
        let containerView = fromViewController.view.superview
        let screenBounds = UIScreen.main.bounds
        
        let finalToFrame = screenBounds
        let finalFromFrame = finalToFrame.offsetBy(dx: screenBounds.size.width, dy: 0)
        
        toViewController.view.frame = finalToFrame.offsetBy(dx: -screenBounds.size.width, dy: 0)
        containerView!.addSubview(toViewController.view)
        
        let alert = FloatingTabBar()

        //for holding the tabbar in place
        if  let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let window = appDelegate.window {
            
            let xpp = 15//self.view.frame.width / 2 - (self.view.frame.width - 30 / 2)
            alert.frame = CGRect(x: CGFloat(xpp), y: window.frame.height - 60, width: window.frame.width - 30 , height: 55)
            alert.layer.shadowColor = UIColor.black.cgColor
            alert.layer.shadowOpacity = 0.6
            alert.layer.shadowOffset = CGSize(width: 1, height: 1.3)
            alert.layer.shadowRadius = 2
            window.addSubview(alert)
        }

        
        
        UIView.animate(withDuration: 0.3, animations: {
            toViewController.view.frame = finalToFrame
            fromViewController.view.frame = finalFromFrame
            }, completion: { finished in
//                let fromVC = self.source
//                let toVC = self.destination
//                fromVC.present(toVC, animated: false, completion: nil)
                //remove after 0.3 seconds
                alert.alpha = 0
                alert.removeFromSuperview()
                
                let fromVC: UIViewController = self.source
                fromVC.dismiss(animated: false, completion: nil)
        })
    }
    
    private func animateSwipeDown() {
        let toViewController = destination
        let fromViewController = source
        
        let containerView = fromViewController.view.superview
        let screenBounds = UIScreen.main.bounds
        
        let finalToFrame = screenBounds
        let finalFromFrame = finalToFrame.offsetBy(dx: 0, dy: screenBounds.size.height)
        
        toViewController.view.frame = finalToFrame.offsetBy(dx: 0, dy: -screenBounds.size.height)
        containerView?.addSubview(toViewController.view)
        
        UIView.animate(withDuration: 0.5, animations: {
            toViewController.view.frame = finalToFrame
            fromViewController.view.frame = finalFromFrame
            }, completion: { finished in
//                let fromVC = self.source
//                let toVC = self.destination
//                fromVC.present(toVC, animated: false, completion: nil)
                let fromVC: UIViewController = self.source
                fromVC.dismiss(animated: false, completion: nil)

        })
    }
    
    private func animateGrowScale() {
        let toViewController = destination
        let fromViewController = source
        
        let containerView = fromViewController.view.superview
        let originalCenter = fromViewController.view.center
        
        toViewController.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        toViewController.view.center = originalCenter
        
        containerView?.addSubview(toViewController.view)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            toViewController.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: { finished in
                let fromVC = self.source
                let toVC = self.destination
                fromVC.present(toVC, animated: false, completion: nil)
        })
    }
    
    private func animateCornerRotate() {
        let point = CGPoint(x: 0, y: 0)
        let toViewController = destination
        let fromViewController = source
        
        toViewController.view.layer.anchorPoint = point

        fromViewController.view.layer.anchorPoint = point
        
        toViewController.view.layer.position = point
        fromViewController.view.layer.position = point
        
        let containerView: UIView? = fromViewController.view.superview
        toViewController.view.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
        containerView?.addSubview(toViewController.view)
        
        UIView.animate(withDuration:0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [], animations: {
            fromViewController.view.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
            toViewController.view.transform = CGAffineTransform.identity
            }, completion: { finished in
                let fromVC: UIViewController = self.source
                let toVC: UIViewController = self.destination
                fromVC.present(toVC, animated: false, completion: nil)
        })
    }
}

// MARK: Unwind Segue class
class CustomUnwindSegue: UIStoryboardSegue {
    
    var animationType: CustomSegueAnimation = .Push
    
    override func perform() {
        switch animationType {
        case .Push:
            animatePush()
        case .SwipeDown:
            animateSwipeDown()
        case .GrowScale:
            animateGrowScale()
        case .CornerRotate:
            animateCornerRotate()
        }
    }
    
    private func animatePush() {
        let toViewController = destination
        let fromViewController = source
        
        let containerView = fromViewController.view.superview
        let screenBounds = UIScreen.main.bounds
        
        let finalToFrame = screenBounds
        let finalFromFrame = finalToFrame.offsetBy(dx: -screenBounds.size.width, dy: 0)
        
        toViewController.view.frame = finalToFrame.offsetBy(dx: screenBounds.size.width, dy: 0)
        containerView?.addSubview(toViewController.view)
        
        let alert = FloatingTabBar()

        //for holding the tabbar in place
        if  let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let window = appDelegate.window {
            
            let xpp = 15//self.view.frame.width / 2 - (self.view.frame.width - 30 / 2)
            alert.frame = CGRect(x: CGFloat(xpp), y: window.frame.height - 60, width: window.frame.width - 30 , height: 55)
            alert.layer.shadowColor = UIColor.black.cgColor
            alert.layer.shadowOpacity = 0.6
            alert.layer.shadowOffset = CGSize(width: 1, height: 1.3)
            alert.layer.shadowRadius = 2
            window.addSubview(alert)
        }

        UIView.animate(withDuration:0.3, animations: {
            toViewController.view.frame = finalToFrame
            fromViewController.view.frame = finalFromFrame
            }, completion: { finished in
//                let fromVC: UIViewController = self.source
//                fromVC.dismiss(animated: false, completion: nil)
                alert.alpha = 0
                alert.removeFromSuperview()
                
                let fromVC = self.source
                let toVC = self.destination
                fromVC.present(toVC, animated: false, completion: nil)

        })
    }
    
    private func animateSwipeDown() {
        let toViewController = destination
        let fromViewController = source
        
        let containerView = fromViewController.view.superview
        let screenBounds = UIScreen.main.bounds
        
        let finalToFrame = screenBounds
        let finalFromFrame = finalToFrame.offsetBy(dx: 0, dy: -screenBounds.size.height)
        
        toViewController.view.frame = finalToFrame.offsetBy(dx: 0, dy: screenBounds.size.height)
        containerView?.addSubview(toViewController.view)
        
        UIView.animate(withDuration:0.5, animations: {
            toViewController.view.frame = finalToFrame
            fromViewController.view.frame = finalFromFrame
            }, completion: { finished in
                let fromVC: UIViewController = self.source
                fromVC.dismiss(animated: false, completion: nil)
        })
    }
    
    private func animateGrowScale() {
        let toViewController = destination
        let fromViewController = source
        
        fromViewController.view.superview?.insertSubview(toViewController.view, at: 0)
        
        UIView.animate(withDuration:0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            fromViewController.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
            }, completion: { finished in
                let fromVC = self.source
                fromVC.dismiss(animated: false, completion: nil)
        })
    }
    
    private func animateCornerRotate() {
        let toViewController = destination
        let fromViewController = source
        let point = CGPoint(x: 0, y: 0)

        
        toViewController.view.layer.anchorPoint = point
        fromViewController.view.layer.anchorPoint = point
        
        toViewController.view.layer.position = point
        fromViewController.view.layer.position = point
        
        let containerView = fromViewController.view.superview
        containerView?.addSubview(toViewController.view)
        
        UIView.animate(withDuration:0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [], animations: {
            fromViewController.view.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
            toViewController.view.transform = CGAffineTransform.identity
            }, completion: { finished in
                let fromVC = self.source
                fromVC.dismiss(animated: false, completion: nil)
        })

    }
}



//
//private func animatePush() {
//    let toViewController = destination
//    let fromViewController = source
//
//    let containerView = fromViewController.view.superview
//    let screenBounds = UIScreen.main.bounds
//
//    let finalToFrame = screenBounds
//    let finalFromFrame = CGRectOffset(finalToFrame, screenBounds.size.width, 0)
//
//    toViewController.view.frame = CGRectOffset(finalToFrame, -screenBounds.size.width, 0)
//    containerView?.addSubview(toViewController.view)
//
//    UIView.animate(withDuration:0.5, animations: {
//        toViewController.view.frame = finalToFrame
//        fromViewController.view.frame = finalFromFrame
//        }, completion: { finished in
//            let fromVC: UIViewController = self.source
//            fromVC.dismissViewControllerAnimated(false, completion: nil)
//    })
//}
//
//
//
//
//private func animatePush() {
//    let toViewController = destination
//    let fromViewController = source
//
//    let containerView = fromViewController.view.superview
//    let screenBounds = UIScreen.main.bounds
//
//    let finalToFrame = screenBounds
//    let finalFromFrame = CGRectOffset(finalToFrame, screenBounds.size.width, 0)
//
//    toViewController.view.frame = CGRectOffset(finalToFrame, -screenBounds.size.width, 0)
//    containerView?.addSubview(toViewController.view)
//
//    UIView.animate(withDuration:0.5, animations: {
//        toViewController.view.frame = finalToFrame
//        fromViewController.view.frame = finalFromFrame
//        }, completion: { finished in
//            let fromVC: UIViewController = self.source
//            fromVC.dismissViewControllerAnimated(false, completion: nil)
//    })
