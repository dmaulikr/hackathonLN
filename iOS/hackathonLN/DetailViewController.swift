//
//  DetailViewController.swift
//  hackathonLN
//
//  Created by f0go on 9/25/15.
//  Copyright (c) 2015 f0go. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class DetailViewController: UIViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, AVAudioPlayerDelegate {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var holderHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryWidth: NSLayoutConstraint!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var noteHeight: NSLayoutConstraint!
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var notificationText: UILabel!
    
    var postID: Int!
    var jsonPost: JSON!
    var audioRecorder: AVAudioRecorder!
    var audioJSON: [NSData] = []
    var imageToShare = UIImage()
    var startPlayer: AVAudioPlayer!
    var stopPlayer: AVAudioPlayer!
    var notePlayer: AVAudioPlayer!
    
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    
    override func viewDidLoad() {
        self.navigationController?.interactivePopGestureRecognizer.delegate = self
        
        
        
        var startSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("start", ofType: "wav")!)
        startPlayer = AVAudioPlayer(contentsOfURL: startSound, error: nil)
        startPlayer.prepareToPlay()
        
        var stopSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("stop", ofType: "wav")!)
        stopPlayer = AVAudioPlayer(contentsOfURL: stopSound, error: nil)
        stopPlayer.prepareToPlay()

        let url = NSURL(string: "http://contenidos.lanacion.com.ar/json/nota/\(postID)")
        Utils.makeJsonRequest(url!, callback: { (json, error) -> Void in
            if error != nil {
                println(error)
            }else {
                let imageURL = "http://bucket.lanacion.com.ar" + json["imagenes"][0]["src"].stringValue
                Utils.getImageFromUrl(imageURL, callback: { (image) -> Void in
                    if image != nil {
                        self.image.image = image
                        self.imageToShare = image
                    }else {
                        self.image.image = UIImage(named: "noDisp")
                    }
                })
                self.jsonPost = json
                self.titleLabel.text = json["titulo"][0]["valor"].stringValue
                self.titleLabel.sizeToFit()
                self.titleHeight.constant = self.titleLabel.frame.height
                self.categoryLabel.text = json["categoria"]["valor"].stringValue.uppercaseString
                self.categoryLabel.sizeToFit()
                self.categoryWidth.constant = self.categoryLabel.frame.width + 30
                self.date.text = json["fecha"].stringValue
                self.note.text = self.parseContent(json["contenido"])
                self.note.sizeToFit()
                self.noteHeight.constant = self.note.frame.height
                self.holderHeight.constant = self.noteHeight.constant - self.titleHeight.constant
                
                self.myUtterance = AVSpeechUtterance(string: self.note.text)
                self.myUtterance.rate = 0.1
                if Globals.sound == true {
                    self.synth.speakUtterance(self.myUtterance)
                }

                self.getVoiceNotes()
            }
        }, retryCount: 0)
    }
    
    func getVoiceNotes(){
        self.audioJSON = []
        var query = PFQuery(className:"Audios")
        query.whereKey("userID", equalTo: Globals.user.username!)
        query.whereKey("url", equalTo: "http://www.lanacion.com.ar/" + jsonPost["url"].stringValue)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                println("Successfully retrieved \(objects!.count) scores.")
                if let objects = objects {
                    for object in objects {
                        object.valueForKey("audio")!.getDataInBackgroundWithBlock({ (data, error) -> Void in
                            if error != nil {
                                println(error)
                            }else {
                                self.audioJSON.append(NSData(data: data!))
                                self.collection.reloadData()
                            }
                        })
                    }
                }
            } else {
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
    }
    
    func parseContent(json: JSON) -> String {
        var parsedContent = ""

        for i: Int in 0..<json.count {
            if json[i]["valor"].stringValue != "" {
                parsedContent = parsedContent + json[i]["valor"].stringValue
            }else {
                for e: Int in 0..<json[i]["valor"].count {
                    parsedContent = parsedContent + json[i]["valor"][e]["valor"].stringValue
                }
            }
        }
        
        return parsedContent
    }
    
    @IBAction func recButton(sender: AnyObject) {
        println("START RECORDING")
        
        startPlayer.play()
        
        delay(0.4, closure: { () -> () in
            var err = NSErrorPointer()
            var audioSession:AVAudioSession = AVAudioSession.sharedInstance()
            audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
            audioSession.setActive(true, error: nil)
            audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker, error: err)
            
            var documents: AnyObject = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.DocumentDirectory,  NSSearchPathDomainMask.UserDomainMask, true)[0]
            var str =  documents.stringByAppendingPathComponent("recordTest.m4a")
            var url = NSURL.fileURLWithPath(str as String)
            
            var recordSettings = [AVFormatIDKey:kAudioFormatMPEG4AAC]
            
            println("url : \(url)")
            var error: NSError?
            
            self.audioRecorder = AVAudioRecorder(URL:url, settings: recordSettings as [NSObject : AnyObject], error: &error)
            if let e = error {
                println(e.localizedDescription)
            } else {
                self.audioRecorder.record()
            }
        })
    }
    
    @IBAction func stopButton(sender: AnyObject) {
        println("STOP RECORDING")
        audioRecorder.stop()
        
        stopPlayer.play()

        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var getImagePath = paths.stringByAppendingPathComponent("recordTest.m4a")

        let data = NSData(contentsOfFile: getImagePath)
        
        self.notificationText.text = "Subiendo audio..."
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.notificationView.alpha = 1
        })
        
        var saveData = PFObject(className:"Audios")
        saveData.setValue(PFFile(data: data!), forKey: "audio")
        saveData.setValue("http://www.lanacion.com.ar/" + jsonPost["url"].stringValue, forKey: "url")
        saveData.setValue(Globals.user.username, forKey: "userID")
        
        saveData.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            if error != nil {
                println(error)
                self.notificationText.text = "Error de conexión"
            }else {
                println(succeeded)
                self.notificationText.text = "Subida completa"
                
                self.delay(0.8) {
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.notificationView.alpha = 0
                    })
                }
                
                self.getVoiceNotes()
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != audioJSON.count {
            synth.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
            var error = NSErrorPointer()
            
            notePlayer = AVAudioPlayer(data: audioJSON[indexPath.row], error: error)
            notePlayer.prepareToPlay()
            
            notePlayer.prepareToPlay()
            notePlayer.play()
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return audioJSON.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DetailCollectionCell", forIndexPath: indexPath) as! DetailCollectionCell
        cell.label.text = "Audio \(indexPath.row + 1)"
        if indexPath.row == audioJSON.count {
            cell.playIcon.image = nil
            cell.label.text = ""
        }else {
            cell.playIcon.image = UIImage(named: "play")
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var ret:CGSize!
        
        let flowlayout = collectionViewLayout as! UICollectionViewFlowLayout
        ret = flowlayout.itemSize
        
        ret.width = 138
        ret.height = 60
        
        return ret
    }
    @IBAction func shareButton(sender: AnyObject) {
        if let shareURL = NSURL(string: "http://javadox.com/crowsound.html?userId=" + Globals.user.username! + "&newsUrl=http://www.lanacion.com.ar/" + jsonPost["url"].stringValue) {
            let text = "#CrowSound"
            var objectsToShare = []
            
            objectsToShare = [text, imageToShare, shareURL]
            
            let activityVC = UIActivityViewController(activityItems: objectsToShare as [AnyObject], applicationActivities: nil)
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func backButton(sender: AnyObject) {
        synth.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == UIEventSubtype.MotionShake {
            synth.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}