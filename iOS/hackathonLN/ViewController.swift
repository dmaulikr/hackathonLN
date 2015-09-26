//
//  ViewController.swift
//  hackathonLN
//
//  Created by f0go on 9/25/15.
//  Copyright (c) 2015 f0go. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var onoffButton: UIButton!
    
    var lastNewsJSON: JSON = []
    
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    
    override func viewDidLoad() {
        if Globals.localStorage.objectForKey("sound") != nil {
            Globals.sound = Globals.localStorage.objectForKey("sound")!.boolValue
            if Globals.sound == false {
                onoffButton.setImage(UIImage(named: "soundOFF"), forState: .Normal)
            }else {
                onoffButton.setImage(UIImage(named: "soundON"), forState: .Normal)
            }
        }
        getLastNews()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        synth.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        vc.postID = lastNewsJSON[indexPath.row]["id"].intValue
        self.navigationController?.pushViewController(vc as DetailViewController, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lastNewsJSON.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LastNewsCell", forIndexPath: indexPath) as! LastNewsCell
        
        cell.categoryWidth.constant = 0
        cell.categoryHeight.constant = 0
        
        cell.categoryLabel.text = lastNewsJSON[indexPath.row]["categoria"]["valor"].stringValue.uppercaseString
        cell.categoryLabel.sizeToFit()
        cell.categoryWidth.constant = cell.categoryLabel.frame.width + 30
        cell.categoryHeight.constant = 25
        
        cell.date.text = lastNewsJSON[indexPath.row]["fecha"].stringValue
        
        cell.title.text = lastNewsJSON[indexPath.row]["titulo"][0]["valor"].stringValue
        
        myUtterance = AVSpeechUtterance(string: cell.title.text)
        myUtterance.rate = 0.1
        synth.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        if Globals.sound == true {
            synth.speakUtterance(myUtterance)
        }
        
        cell.backImage.image = nil
        
        if lastNewsJSON[indexPath.row]["imagenes"].count > 0 {
            let imageURL = "http://bucket.lanacion.com.ar" + lastNewsJSON[indexPath.row]["imagenes"][0]["src"].stringValue
            Utils.getImageFromUrl(imageURL, callback: { (image) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if let cellToUpdate = collectionView.cellForItemAtIndexPath(indexPath) {
                        let blur = image.applyBlurWithRadius(15, blurType: BOXFILTER, tintColor: UIColor.clearColor(), saturationDeltaFactor: 1, maskImage: nil)
                        cell.backImage.image = blur
                    }
                })
            })
        }else {
            let blur = UIImage(named: "noDisp")!.applyBlurWithRadius(15, blurType: BOXFILTER, tintColor: UIColor.clearColor(), saturationDeltaFactor: 1, maskImage: nil)
            cell.backImage.image = blur
        }

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var ret:CGSize!
        
        let flowlayout = collectionViewLayout as! UICollectionViewFlowLayout
        ret = flowlayout.itemSize
        
        ret.width = Globals.screenSize.width
        ret.height = Globals.screenSize.height + 10
            
        return ret
    }

    
    func getLastNews(){
        var url = NSURL(string: "http://contenidos.lanacion.com.ar/json/acumulado-ultimas")
        Utils.makeJsonRequest(url!, callback: { (json, error) -> Void in
            if error != nil {
                println(error)
            }else {
                self.lastNewsJSON = json["items"]
                self.collection.reloadData()
            }
        }, retryCount: 0)
    }

    @IBAction func onoffButton(sender: AnyObject) {
        if Globals.sound == false {
            Globals.sound = true
            onoffButton.setImage(UIImage(named: "soundON"), forState: .Normal)
        }else {
            Globals.sound = false
            synth.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
            onoffButton.setImage(UIImage(named: "soundOFF"), forState: .Normal)
        }
        Globals.localStorage.setObject(Globals.sound.boolValue, forKey: "sound")
        Globals.localStorage.synchronize()
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == UIEventSubtype.MotionShake {
            synth.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        }
    }
}

