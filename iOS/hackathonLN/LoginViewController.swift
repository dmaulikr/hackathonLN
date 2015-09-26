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
            login.logInWithReadPermissions(["public_profile", "user_photos"], handler: { (result, error) -> Void in
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
}