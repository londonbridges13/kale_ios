//
//  SettingsViewController.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 1/5/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Jelly
import NVActivityIndicatorView
import RealmSwift
import Alamofire
import Kingfisher
import ImagePicker
import MessageUI


class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImagePickerDelegate,MFMailComposeViewControllerDelegate  {

    @IBOutlet var tableview: UITableView!
    
    var loadview : UIView?
    var actIndi : NVActivityIndicatorView?
    var options = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        tableview.delegate = self
        tableview.dataSource = self
        
//        self.options.append("Share Undercooked 👌")
        self.options.append("Change Name")
        self.options.append("Update Profile Picture")
        self.options.append("Change Password")
        self.options.append("Feedback / Support")
        self.options.append("Contact Us")
        self.tableview.reloadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "settingscell", for: indexPath)
        cell.textLabel?.text = options[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
//        if indexPath.row == 0{
//            // invite user
//            self.invite_other()
        if indexPath.row == 0{
            self.go_change_name()
        }else if indexPath.row == 1{
            self.set_new_image()//self.select_new_image()
        }else if indexPath.row == 2{
            self.go_change_password()
        }else if indexPath.row == 3{
            self.give_feedback()
        }else{
            self.sendEmail()
        }
    }

    func invite_other(){
        print("Displaying UIActivity Controller")
        let textToShare = "I know how much you love food, check out Undercooked"
        
        if let myWebsite = NSURL(string: "") {
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            //
            
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    
    func update_profile_pic(image : UIImage){
        start_loading()
        
        let realm = try! Realm()
        var user = realm.objects(User).first
        if user != nil && user?.access_token != nil && user?.client_token != nil{
            // API Call for user profile pic, might not have one
            let data = UIImagePNGRepresentation(UIImage(named: "back_button_image")!) as NSData!
            print(UIImage(named: "back_button_image")!)
            print("")
            let pic : Data = UIImageJPEGRepresentation(image, 1)!
            let pic_b64 = pic.base64EncodedString()
            
            let parameters: Parameters = [
                "access_token": user!.client_token!,
                "utoken": user!.access_token!,
                "photo_path": "data:image/jpeg;base64,\(pic_b64)"
                
            ]
            let URL = try! URLRequest(url: "https://secret-citadel-33642.herokuapp.com/api/v1/users/update_profile_pic", method: .post)
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    print("pic_b64 : \(pic_b64)")
                    for (key, value) in parameters {
                        multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                    }
            },
                with: URL,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            print(response.result.value)
                            self.end_loading()
                        }
                    case .failure(let encodingError):
                        print(encodingError)
                        self.end_loading()
                    }
            }
            )
            
        }
        
    }
    
    func set_new_image(){
        let imagePicker = ImagePickerController()
        imagePicker.imageLimit = 1

        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }

    
    
    
    
    // ImagePicker Delegates
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard images.count > 0 else { return }
        
        if images.first != nil{
            self.update_profile_pic(image: images.first!)
        }
//        let lightboxImages = images.map {
//            return LightboxImage(image: $0)
//        }
//        
//        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
//        imagePicker.present(lightbox, animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if images.first != nil{
            self.update_profile_pic(image: images.first!)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }

    
    
    
    //Send Email 
    
    func sendEmail(){
        var systemVersion = UIDevice.current.systemVersion
        let version =
            Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
                as? String
        var device = UIDevice.current.modelName
        
        if  (MFMailComposeViewController.canSendMail()) {
            print("Can send email.")
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            //Set the subject and message of the email
            mailComposer.setSubject("About Undercooked")
            mailComposer.setMessageBody("\n \n\n\n\n \n\n\n_____________________   \nPhone Version: \(systemVersion),\n App Version: \(version!),\n \(device)", isHTML: false)
            mailComposer.setToRecipients(["undercookedapp@gmail.com"])
            
            self.present(mailComposer, animated: true, completion: nil)
        }
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    

    
    
    
    
    
    //Loading, for uploading image
    
    func start_loading(){
        UIApplication.shared.beginIgnoringInteractionEvents()
        var yp = view.frame.height / 2 - (180 / 2)
        var xp = view.frame.width / 2 - (270 / 2)
        
        loadview = UIView(frame: CGRect(x: xp, y: yp, width: 270, height: 180))
        
        let loadLabel = UILabel(frame: CGRect(x: 0, y: 15, width: (loadview?.frame.width)!, height: 45))
        loadLabel.textColor = UIColor.white
        loadLabel.textAlignment = .center
        loadLabel.font = UIFont(name: "SanchezSlab", size: 35)
        loadLabel.adjustsFontSizeToFitWidth = true
        loadLabel.minimumScaleFactor = 0.1
        loadLabel.text = "Uploading"
        loadview?.addSubview(loadLabel)
        
        
        let pop_red = UIColor(colorLiteralRed: 255/255, green: 103/255, blue: 102/255, alpha: 1)
        
        loadview?.backgroundColor = pop_red
        loadview?.layer.cornerRadius = 5
        loadview?.alpha = 0
        self.view.addSubview(self.loadview!)
        loadview?.fadeIn(duration: 0.6)
        
        var delayInSeconds = 0.25
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            
            var size : CGFloat = 37
            var xxp = (self.loadview?.frame.width)! / 2 - (size / 2)
            var hp = (self.loadview?.frame.height)! / 2 - (size / 2)
            let frame = CGRect(x: xxp, y: hp, width: size, height: size)
            
            self.actIndi = NVActivityIndicatorView(frame: frame, type: .lineScale, color: UIColor.white, padding: 3)
            self.actIndi?.startAnimating()
            self.actIndi?.alpha = 0
            
            self.loadview?.addSubview(self.actIndi!)
            
            self.actIndi?.fadeIn(duration: 0.2)
        }
        
//        delayInSeconds = 1.25
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
//            loadview.fadeOut(duration: 0.6)
//            self.tableview.reloadData()
//        }
        
    }
    
    func end_loading(){
        UIApplication.shared.endIgnoringInteractionEvents()
        let delayInSeconds = 0.05
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            self.loadview?.fadeOut(duration: 0.6)
            self.tableview.reloadData()
        }//yeah
    }
    
    
    

    func go_change_password(){
        performSegue(withIdentifier: "changepassword", sender: self)
    }
    
    func go_change_name(){
        performSegue(withIdentifier: "changename", sender: self)
    }
    func give_feedback(){
        self.performSegue(withIdentifier: "s_f", sender: self)
    }
    
    @IBAction func unwind_to_settings(segue: UIStoryboardSegue){
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "changepassword"{
            let vc : ChangePasswordViewController = segue.destination as! ChangePasswordViewController
        }
        if segue.identifier == "s_f"{
            let vc: FeedbackViewController = segue.destination as! FeedbackViewController
            vc.from = "settings"
        }
    }
    

}
public extension UIDevice {
    var modelName: String {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            let DEVICE_IS_SIMULATOR = true
        #else
            let DEVICE_IS_SIMULATOR = false
        #endif
        
        var machineString = String()
        
        if DEVICE_IS_SIMULATOR == true
        {
            if let dir = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                machineString = dir
            }
        }
        else {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            machineString = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8 , value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
        }
        switch machineString {
        case "iPod4,1":                                 return "iPod Touch 4G"
        case "iPod5,1":                                 return "iPod Touch 5G"
        case "iPod7,1":                                 return "iPod Touch 6G"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone 9,4":                 return "iPhone 7 Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7 inch)"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9 inch)"
        case "AppleTV5,3":                              return "Apple TV"
        default:                                        return machineString
        }
    }
}
