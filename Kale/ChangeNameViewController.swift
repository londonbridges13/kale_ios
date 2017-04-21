//
//  ChangeNameViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 1/7/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

class ChangeNameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var nameTX : UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load_name()
        
        nameTX.delegate = self
        nameTX.becomeFirstResponder()
        nameTX.returnKeyType = .done
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (self.nameTX.text?.characters.count)! > 0{
            self.update_name()
        }
        return true
    }
    
    func update_name(){
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken" : user!.access_token!,
                "uname" : nameTX.text!,
            ]
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/users/edit_name", method: .post, parameters: parameters).responseJSON { (response) in
                if let result = response.result.value as? String{
                    // There was an error
                    print(response.result.value)
                    self.display_invalid_alert(message: result)
                }else{
                    // it worked. should display user info in the response
                    // save password
                    self.save_name()
                    self.display_success_alert(message: "Successfully changed Name")
                }
            }
        }
    }
    
    
    func save_name(){
        let realm = try! Realm()
        var user = realm.objects(User).first
        try! realm.write{
            user!.name = self.nameTX.text!
            print("Saving Name to Realm")
        }
    }
    
    func load_name(){
        let realm = try! Realm()
        var user = realm.objects(User).first
        try! realm.write{
            if user!.name != nil{
                self.nameTX.text = user!.name!
            }else{
                // display email
                self.nameTX.text = user!.email!
            }
            print("Displaying Name from Realm")
        }
    }
    
    func display_success_alert(message: String){
        let alertController = UIAlertController(title: "Success", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Great", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            print("You pressed OK")
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func display_invalid_alert(message: String){
        let alertController = UIAlertController(title: "Network Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
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
