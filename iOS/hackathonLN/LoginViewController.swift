//
//  LoginViewController.swift
//  hackathonLN
//
//  Created by f0go on 9/26/15.
//  Copyright (c) 2015 f0go. All rights reserved.
//

import Foundation
import UIKit
import Social
import MobileCoreServices

class LoginViewController: UIViewController {
    
    @IBOutlet weak var backImage: UIImageView!
    
    override func viewDidLoad() {
        let blur = UIImage(named: "globos")!.applyBlurWithRadius(15, blurType: BOXFILTER, tintColor: UIColor.clearColor(), saturationDeltaFactor: 1, maskImage: nil)
        backImage.image = blur
    }
    @IBAction func loginButton(sender: AnyObject) {
        if FBSDKProfile.currentProfile() == nil {
            FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "onProfileUpdated:", name:FBSDKProfileDidChangeNotification, object: nil)
            let login: FBSDKLoginManager = FBSDKLoginManager()
            login.logInWithReadPermissions(["public_profile"], handler: { (result, error) -> Void in
                if error != nil {
                    println(error)
                }else if result.isCancelled {
                    println("Cancel")
                }else {
                    println("👤 Facebook Login")
                }
            })
        }else {
            println("👤 Facebook Login")
        }
    }
    
    func onProfileUpdated(notification: NSNotification) {
        self.createUser(FBSDKProfile.currentProfile())
    }
    
    func createUser(fbUser: FBSDKProfile){
        Globals.localStorage.setObject(fbUser.userID, forKey: "user")
        Globals.localStorage.setObject(fbUser.userID, forKey: "pass")
        Globals.localStorage.synchronize()
        
        Globals.user = PFUser()
        Globals.user.username = fbUser.userID
        Globals.user.password = fbUser.userID
        
        Globals.user.setValue(fbUser.name, forKey: "name")
        
        Globals.user.signUpInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                var vc = self.storyboard?.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
                self.presentViewController(vc, animated: true, completion: nil)
            } else {
                if error!.code == 202 {
                    self.login(fbUser.userID, passValue: fbUser.userID)
                }
            }
        }
    }
    
    
    func login(userValue: String, passValue: String) {
        PFUser.logInWithUsernameInBackground(userValue, password:passValue) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                println("👋 Welcome back \(user?.username)")
                Globals.localStorage.setObject(userValue, forKey: "user")
                Globals.localStorage.setObject(passValue, forKey: "pass")
                Globals.localStorage.synchronize()
                
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("NavController") as! NavController
                self.presentViewController(vc, animated: false, completion: nil)
            } else {
                let alert = UIAlertView()
                alert.title = "😓 Login error"
                alert.message = error!.userInfo?["error"] as! NSString as String
                alert.addButtonWithTitle("Ok")
                alert.show()
            }
        }
    }
}