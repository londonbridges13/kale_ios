//
//  SignUpInAlertViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 11/30/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import FacebookLogin

import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

class SignUpInAlertViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet var topLabel: UILabel!
    @IBOutlet var emailTXField: UITextField!
    @IBOutlet var passwordTXField: UITextField!
    
    @IBOutlet var emailView: UIView!
    @IBOutlet var passwordView: UIView!

//    @IBOutlet var backButton: UIButton!
    @IBOutlet var goButton: UIButton!

    @IBOutlet var segueHomeButton: UIButton!
    @IBOutlet var segueTopicsButton: UIButton!
    @IBOutlet var facebook_button: UIButton!

    var labeltext : String?
    var email : String?
    var password : String?
    var access_token : String?
    var username : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTXField.delegate = self
        self.passwordTXField.delegate = self
        self.topLabel.text = self.labeltext
        self.emailView.layer.cornerRadius = 5
        self.passwordView.layer.cornerRadius = 5
        self.emailView.layer.borderWidth = 1
        self.passwordView.layer.borderWidth = 1
        self.emailView.layer.borderColor = UIColor.gray.cgColor
        self.passwordView.layer.borderColor = UIColor.gray.cgColor
        self.goButton.layer.cornerRadius = 5

        self.facebook_button.addTarget(self, action: "login_with_facebook", for: .touchUpInside)
        
        
        self.get_client_token()
        
        if self.labeltext == "Sign Up"{
            //sign up
            self.goButton.addTarget(self, action: #selector(SignUpInAlertViewController.sign_up), for: .touchUpInside)
        }else{
            //sign in
            self.goButton.addTarget(self, action: #selector(SignUpInAlertViewController.sign_in), for: .touchUpInside)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissMe(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func invalid_entry(){

        invalid_password()
        invalid_email()
    }
    
    func invalid_password(){
        let pop_red = UIColor(colorLiteralRed: 255/255, green: 103/255, blue: 102/255, alpha: 1)

        self.passwordView.shake()
        self.passwordView.layer.borderColor = pop_red.cgColor
    }
    
    func invalid_email(){
        let pop_red = UIColor(colorLiteralRed: 255/255, green: 103/255, blue: 102/255, alpha: 1)

        self.emailView.shake()
        self.emailView.layer.borderColor = pop_red.cgColor
    }
    
    //textfield 
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.emailTXField.isEditing == true{
            self.passwordTXField.becomeFirstResponder()
            return true
        }else{
            self.passwordTXField.resignFirstResponder()
            if self.labeltext == "Sign Up"{
                //sign up
                self.sign_up()
            }else{
                //sign in
                self.sign_in()
            }
            return true
        }
    }
    
    
    func sign_up(){
        print("Signing Up")
        if valid_email(check_email: self.emailTXField.text!) == true{
            self.email = self.emailTXField.text!
            if self.valid_password() == true{
                // send request
                request_sign_up(email: self.email!, password: self.password!, access_token: self.access_token!)
            }else{
                // Invalid Password
                print("Invalid Password")
                self.invalid_password()
            }
        }else{
            // Invalid Email
            print("Invalid Email")
            self.invalid_email()
        }
    }
    
    
    func sign_in(){
        print("Signing In")
        if valid_email(check_email: self.emailTXField.text!) == true{
            self.email = self.emailTXField.text!
            if self.valid_password() == true{
                // send request 
                request_sign_in(email: self.email!, password: self.password!, access_token: self.access_token!)
            }else{
                // Invalid Password
                print("Invalid Password")
                self.invalid_password()
            }
        }else{
            // Invalid Email
            print("Invalid Email")
            self.invalid_email()
        }
    }
    
    
    func request_sign_in(email : String, password : String, access_token : String, user_token : String = ""){
        
        let parameters: Parameters = [
            "access_token": access_token,
            "uemail": email,
            "upassword": password,
            "utoken": user_token
        ]
        
        Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/users/signin", method: .post, parameters: parameters).responseJSON { (response) in
            if let result = response.result.value as? NSDictionary{
//                var id = result["id"] as? Int
                var name = result["name"] as? String
                if name != nil{
                    if name!.characters.count > 0{
                        self.username = name!
                        self.set_user_name(name: name!) // This works only if there is a name here
                    }
                }
                var user_token = result["access_token"] as? String
                if user_token != nil{
                    // Successfully signed in, segue to Home Tab
                    print(user_token!)
                    self.set_user_token(user_token: user_token!)
                    self.set_user_email_and_password(email: email, password: password)
                    self.segueHomeButton.sendActions(for: .touchUpInside)
                }else{
                    // Invalid Sign In
                    print("Invalid Email/Password")
                    self.invalid_entry()
                }
            }else{
                // Invalid Sign In
                print("Invalid Email/Password")
                self.invalid_entry()
            }
        }

    }
    
    func request_sign_up(email : String, password : String, access_token : String, user_token : String = ""){
        print("requesting sign up")
        let parameters: Parameters = [
            "access_token": access_token,
            "uemail": email,
            "upassword": password,
            "utoken": user_token
        ]
        
        Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/users/signup", method: .post, parameters: parameters).responseJSON { (response) in
            if let result = response.result.value as? NSDictionary{
                var name = result["name"] as? String
                if name != nil{
                    self.username = name!
                }
                var new_user_token = result["access_token"] as? String
                if new_user_token != nil{
                    // Successfully signed up, segue to Select Topics
                    print("Successfully signed up, segue to Select Topics")
                    print(new_user_token!)
                    self.set_user_token(user_token: new_user_token!)
                    self.set_user_email_and_password(email: email, password: password)
                    self.segueTopicsButton.sendActions(for: .touchUpInside)
                }else{
                    // Invalid Sign In
                    print("Invalid Email/Password")
                    self.invalid_entry()
                }
            }
        }
    }
    
    
    
    func valid_password() -> Bool{
        if (self.passwordTXField.text?.characters.count)! >= 6{
            // Continue with features
            self.password = self.passwordTXField.text!
            return true
        }else{
            return false
        }
    }
    
    func valid_email(check_email : String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: check_email)
    }
    
    
    func get_client_token(){
        // Grabs the valid token from the user's database
        let realm = try! Realm()
        let user = realm.objects(User).first
        self.access_token = user!.client_token!
        print("Client Token: \(self.access_token)")
        
    }

    func set_user_token(user_token: String){
        // Sets the user's user_token
        let realm = try! Realm()
        let user = realm.objects(User).first
        try! realm.write{
            user!.access_token = user_token
            print("Saved User Token : \(user_token)")
        }
    }
    
    func set_user_email_and_password(email : String, password : String){
        let realm = try! Realm()
        let user = realm.objects(User).first
        try! realm.write{
            user!.password = password
            user!.email = email
        }
    }
    
    func set_user_name(name : String){
        let realm = try! Realm()
        let user = realm.objects(User).first
        try! realm.write{
            user!.name = name
        }
    }
    
    
    
    
    // Facebook
    func login_with_facebook(){
        let login = FBSDKLoginManager()
        login.loginBehavior = FBSDKLoginBehavior.systemAccount
        login.logIn(withReadPermissions: ["public_profile", "email"], from: self, handler: {(result, error) in
            if error != nil {
                //                print("Error :  \(error.description)")
            }
            else if (result?.isCancelled)! {
                
            }
            else {
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "first_name, last_name, picture.type(large), email, name, id, gender"]).start(completionHandler: {(connection, result, error) -> Void in
                    if error != nil{
                        //                        print("Error : \(error.description)")
                    }else{
                        
                        print("userInfo is \(result))")
                        
                        if result != nil{
                            let data:[String:AnyObject] = result as! [String : AnyObject]
                            
                            var id = data["id"] as? String
                            if id != nil{
                                print(id)
                            }
                            
                            var name = data["name"] as? String
                            if name != nil{
                                print(name)
                            }
                            
                            var email = data["email"] as? String
                            if email != nil{
                                print(email)
                            }
                            
                            // profile picture
                            
                            var pic = data["picture"]
                            print(pic)
                            let picture:[String:AnyObject] = pic as! [String : AnyObject]
                            let picture_data = picture["data"]
                            let pic_data:[String:AnyObject] = picture_data as! [String : AnyObject]
                            var picture_url = pic_data["url"] as? String
                            if picture_url != nil{
                                // send to login request with picture_url
                                print(picture_url!)
                                self.request_facebook_login_with_pic(email: email!, name: name!, facebook_id: id!, url: picture_url!)
                            }else{
                                // no picture_url, send login request without it
                                self.request_facebook_login_without_pic(email: email!, name: name!, facebook_id: id!)
                            }
                            
                            
                        }
                        
                    }
                })
            }
            
        })
    }
    
    func request_facebook_login_with_pic(email: String, name: String, facebook_id: String, url: String){
        
        let parameters: Parameters = [
            "access_token": self.access_token!,
            "uemail": email,
            "uname": name,
            "ufacebook_id": facebook_id,
            "picture_url": url
        ]
        
        Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/users/login_with_facebook", method: .post, parameters: parameters).responseJSON { (response) in
            print("This is API Response: \(response.result.value)")
            if let result = response.result.value as? NSDictionary{
                self.username = name
                var new_user_token = result["access_token"] as? String
                print(new_user_token)
                if new_user_token != nil{
                    // Successfully signed up/in, check if user has topics
                    print(new_user_token!)
                    self.set_user_token(user_token: new_user_token!)
                    self.save_facebook_details(email: email, name: name, facebook_id: facebook_id)
                    self.does_user_have_topics(access_token: new_user_token!, email: email)
                }else{
                    // Error with Facebook Login, tell user
                    print("Problem Logging into Facebook")
                }
            }
        }

    }
    
    
    func request_facebook_login_without_pic(email: String, name: String, facebook_id: String){
        
        let parameters: Parameters = [
            "access_token": self.access_token!,
            "uemail": email,
            "uname": name,
            "ufacebook_id": facebook_id,
        ]
        
        Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/users/login_with_facebook", method: .post, parameters: parameters).responseJSON { (response) in
            print("This is API Response: \(response.result.value)")

            if let result = response.result.value as? NSDictionary{
                self.username = name
                
                var new_user_token = result["access_token"] as? String
                if new_user_token != nil{
                    // Successfully signed up/in, check if user has topics
                    print(new_user_token!)
                    self.set_user_token(user_token: new_user_token!)
                    self.save_facebook_details(email: email, name: name, facebook_id: facebook_id)
                    self.does_user_have_topics(access_token: new_user_token!, email: email)
                }else{
                    // Error with Facebook Login, tell user
                    print("Problem Logging into Facebook")
                }
            }
        }
        
    }
    
    
    
    func save_facebook_details(email: String, name: String, facebook_id: String){
        // no password used, save facebook_id 
        let realm = try! Realm()
        let user = realm.objects(User).first
        try! realm.write{
            user!.name = name
            user!.facebook_id = facebook_id
            user!.email = email
        }
        
    }
    
    
    func does_user_have_topics(access_token: String, email: String){
        // Checking only because of facebook login. We don't know if this user is login in of signing up with facebook
        var answer : String?
        
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "uemail": email
            ]
            print("User Token: \(access_token)")
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v3/users/does_user_have_topics", method: .post, parameters: parameters).responseJSON { (response) in
                print("This is FB login part 2 API response: \(response.result.value)")
                if response.result.value != nil{
                    if let result = response.result.value as? String {
                        print("Does User Have Topics: \(result)")
                        answer = result
                        if answer == "no"{
                            // No Topics, Segue to Topics
                            self.segueTopicsButton.sendActions(for: .touchUpInside)
                        }else{
                            // Send her through to HomeVC
                            self.segueHomeButton.sendActions(for: .touchUpInside)
                        }
                    }
                }
            }
        }
    }

    
    // Extra Facebook Stuff
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
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
extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
