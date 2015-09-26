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
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("NavController") as! NavController
        self.presentViewController(vc, animated: false, completion: nil)
    }
}