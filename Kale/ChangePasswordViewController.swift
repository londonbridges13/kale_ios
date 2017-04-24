//
//  ChangePasswordViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 1/7/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var old_password_TX: UITextField!
    @IBOutlet var new_password_TX: UITextField!
    @IBOutlet var retype_password_TX: UITextField!
    @IBOutlet var back_Button: UIButton!
    
    var old_pw : String?
    var new_pw : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        old_password_TX.delegate = self
        new_password_TX.delegate = self
        retype_password_TX.delegate = self
        
        self.old_password_TX.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Return")
        if self.old_password_TX.isFirstResponder == true{
            // move to new_passwordTX
            self.new_password_TX.becomeFirstResponder()
            return true
        }else if self.new_password_TX.isFirstResponder == true{
            self.retype_password_TX.becomeFirstResponder()
            return true
        }else{
            // done with the retyping, enter check the passwords
            check_new_password()
            self.retype_password_TX.resignFirstResponder()
            return true
        }
    }
    
    
    func check_new_password(){
        // check if the new password is long enoungh, ad that it matches the old password
        
        if self.new_password_TX.text == self.retype_password_TX.text{
            // matches, now check length
            if (self.new_password_TX.text?.characters.count)! >= 6{
                // user is good, run the password change
                self.change_password(old: self.old_password_TX.text!, new: self.new_password_TX.text!)
            }else{
                // too short of a password
                print("Password is too short")
            }
            
        }else{
            // doesn't match retyped password
            print("Password doesn't match retyped password")
        }
    }
    
    
    func change_password(old : String, new : String){
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken" : user!.access_token!,
                "oldpassword" : old,
                "newpassword" : new
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/users/edit_password", method: .post, parameters: parameters).responseJSON { (response) in
                if let result = response.result.value as? String{
                    // There was an error
                    print(response.result.value)
                    self.display_invalid_alert(message: result)
                }else{
                    // it worked. should display user info in the response
                    // save password
                    self.save_password()
                    self.display_success_alert(message: "Successfully changed password")
                }
            }
        }

    }
    
    
    func save_password(){
        let realm = try! Realm()
        var user = realm.objects(User).first
        try! realm.write{
            user!.password = self.new_password_TX.text!
            print("Saving Password to Realm")
        }
    }

    
    func display_success_alert(message: String){
        let alertController = UIAlertController(title: "Success", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Great", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            print("You pressed OK")
            self.back_Button.sendActions(for: .touchUpInside)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func display_invalid_alert(message: String){
        let alertController = UIAlertController(title: "Invalid Password", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            print("You pressed OK")
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
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
