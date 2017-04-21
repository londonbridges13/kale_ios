//
//  AppDelegate.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 11/28/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let pop_red = UIColor(colorLiteralRed: 255/255, green: 103/255, blue: 102/255, alpha: 1)
    let pop_blue = UIColor(colorLiteralRed: 29/255, green: 171/255, blue: 192/255, alpha: 1)
    let pop_orange = UIColor(colorLiteralRed: 255/255, green: 126/255, blue: 85/255, alpha: 1)
    
    
    
//    func applicationDidFinishLaunching(_ aNotification: Notification) {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool{
        // Override point for customization after application launch.
        print("hi")
//        self.request_token()
//        self.check_user_token() // should be after/ in request above
////        self.check_user()
        
        
        //Realm
        
        let config =     Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 2,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                migration.enumerateObjects(ofType: User.className()) { oldObject, newObject in
//                    if oldSchemaVersion < 1 {
//                        var value = false
//                        newObject!["did_finish_selecting_topics"] = value
//                    }
                    if oldSchemaVersion < 2 {
                        var value = false
                        newObject!["knows_to_swipe_topics"] = value 
                    }
//                    Added newer versions here
//                    if oldSchemaVersion < 2 {
//
//                    }
                }
        }
            
        )
        
        //Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        let realm = try! Realm()
        
        //End Realm
        
        self.request_token()
        self.check_user_token() // should be after/ in request above
//        self.check_user()

        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        self.request_token()

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    func check_user(){
        let realm = try! Realm()
        var user = realm.objects(User).first
        print(user!.email!)
        print(user!.password!)
    }
    
    func check_user_token(){
        print("Checking for user")
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!
            ]
            print("User Token: \(user!.access_token!)")
            Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/users/profile", method: .post, parameters: parameters).responseJSON { (response) in
                if let result = response.result.value as? NSDictionary{
                    var access_token = result["access_token"] as? String
                    if access_token != nil{
                        // Found User, your work is done
                        print("Found User, Your work is done")
                    }else{
                        print("No User Found")
                        // Sign in again, you would have a user.access_token only if you were signed in before
                        if user!.email != nil && user!.password != nil && user!.client_token != nil{
                            self.request_sign_in(email: user!.email!, password: user!.password!, access_token: user!.client_token!)
                            print("Couldn't find User, Requesting Sign In for user_token")
                        }
                    }
                }
            }
            
        }
    }

    
    func request_token(){
        print("Beginning Request")
        var keys: NSDictionary?
        
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
            if let dict = keys {
                let clientId = dict["clientId"] as! String
                let clientSecret = dict["clientSecret"] as! String
                print(clientId)
                print(clientSecret)
                
                let parameters: Parameters = [
                    "client_id": clientId,
                    "client_secret": clientSecret,
                    "grant_type": "client_credentials",
                    "redirect_uri": "http://localhost:9000"
                ]
                Alamofire.request("https://secret-citadel-33642.herokuapp.com/oauth/token", method: .post, parameters: parameters).responseJSON { (response) in
                    if let result = response.result.value as? NSDictionary{
                        var access_token = result["access_token"] as? String
                        if access_token != nil{
                            // Save access token
                            print(access_token!)
                            self.give_user_client_token(client_token: access_token!)
                        }else{
                            print("Invalid Credentials")
                        }
                    }
                }
            }
        }
    }
    

    func give_user_client_token(client_token : String){
        // Checks for local user data, if none, creates a user
        // Then adds client_token to user, so that they can access app for the next 2 hours
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil{
            // We have a user
            try! realm.write {
                user!.launch_count += 1
                user!.client_token = client_token
                print(user!.email)
                print(user!.password)
                print("Launch Count: \(user!.launch_count)")
            }
        }else{
            // No User, Create one
            let gordan = User()
            gordan.launch_count = 1
            gordan.client_token = client_token
            try! realm.write {
                realm.add(gordan)
                print(gordan)
            }
        }
    }
    
    
    
    func request_sign_in(email : String, password : String, access_token : String, user_token : String = ""){
        
        let parameters: Parameters = [
            "access_token": access_token,
            "uemail": email,
            "upassword": password,
            "utoken": user_token
        ]
        
        Alamofire.request("https://secret-citadel-33642.herokuapp.com/api/v1/users/signin", method: .post, parameters: parameters).responseJSON { (response) in
            if let result = response.result.value as? NSDictionary{
                //                var id = result["id"] as? Int
                var name = result["name"] as? String
                if name != nil{
//                    self.username = name!
                }
                var user_token = result["access_token"] as? String
                if user_token != nil{
                    // Successfully signed in, segue to Home Tab
                    print(user_token!)
                    self.set_user_token(user_token: user_token!)
                }else{
                    // Invalid Sign In
                    print("Invalid Email/Password")
                }
            }
        }
        
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

    
}

