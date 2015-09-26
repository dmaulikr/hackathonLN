//
//  Utils.swift
//  hackathonLN
//
//  Created by f0go on 9/25/15.
//  Copyright (c) 2015 f0go. All rights reserved.
//

import Foundation
import UIKit

struct Globals {
    static var imageCache = [String : UIImage]()
    static var screenSize: CGRect = UIScreen.mainScreen().bounds
    static var localStorage: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    static var user = PFUser()
}

class Utils {
    class func makeJsonRequest (url: NSURL, callback: (json: JSON!, error: NSError!) -> Void, retryCount:Int = 0) {
        println("📡 request: \(url)")
        var request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 5)
        
        request.HTTPMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("User-Agent", forHTTPHeaderField: "user-agent")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if error != nil {
                if retryCount == 5 {
                    println("🔥🔥 Request: Error \(error.localizedDescription) \(url)")
                    callback(json: nil, error: error)
                }else {
                    println("🔥🔥 Request: Error Count \(retryCount) \(url)")
                    self.makeJsonRequest(url, callback: callback, retryCount: retryCount + 1)
                }
            } else {
                
                var json = JSON(data: data)
                
                println("👍 Request: \(url)")
                callback(json: json, error: nil)
            }
        })
    }
    
    class func getImageFromUrl(url:String, callback: (image:UIImage!) -> Void) {
        var image = Globals.imageCache[url]
        
        if(image == nil) {
            var imgURL: NSURL = NSURL(string: url)!
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    image = UIImage(data: data)
                    Globals.imageCache[url] = image
                    
                    callback(image: image)
                } else {
                    println("🔥🔥 Image Download Error: \(error.localizedDescription)")
                    callback(image: nil)
                }
            })
            
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                callback(image: image)
            })
        }
    }
}