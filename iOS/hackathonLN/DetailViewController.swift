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
    
    var postID: Int!
    var jsonPost: JSON!
    var audioRecorder: AVAudioRecorder!
    var audioJSON: [NSData] = []
    
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    
    override func viewDidLoad() {
        self.navigationController?.interactivePopGestureRecognizer.delegate = self
        
        let url = NSURL(string: "http://contenidos.lanacion.com.ar/json/nota/\(postID)")
        Utils.makeJsonRequest(url!, callback: { (json, error) -> Void in
            if error != nil {
                println(error)
            }else {
                let imageURL = "http://bucket.lanacion.com.ar" + json["imagenes"][0]["src"].stringValue
                Utils.getImageFromUrl(imageURL, callback: { (image) -> Void in
                    self.image.image = image
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
                self.holderHeight.constant = self.noteHeight.constant
                
                self.myUtterance = AVSpeechUtterance(string: self.note.text)
                self.myUtterance.rate = 0.07
                self.synth.speakUtterance(self.myUtterance)
                self.getVoiceNotes()
            }
        }, retryCount: 0)
    }
    
    func getVoiceNotes(){
        var query = PFQuery(className:"Audios")
        query.whereKey("userID", equalTo: Globals.user.username!)
        query.whereKey("url", equalTo: "http://www.lanacion.com.ar/" + jsonPost["url"].stringValue)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                println("Successfully retrieved \(objects!.count) scores.")
                if let objects = objects {
                    for object in objects {
                        println(object.allKeys)
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
        var audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        audioSession.setActive(true, error: nil)
        
        var documents: AnyObject = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.DocumentDirectory,  NSSearchPathDomainMask.UserDomainMask, true)[0]
        var str =  documents.stringByAppendingPathComponent("recordTest.m4a")
        var url = NSURL.fileURLWithPath(str as String)
        
        var recordSettings = [AVFormatIDKey:kAudioFormatMPEG4AAC]
        
        println("url : \(url)")
        var error: NSError?
        
        audioRecorder = AVAudioRecorder(URL:url, settings: recordSettings as [NSObject : AnyObject], error: &error)
        if let e = error {
            println(e.localizedDescription)
        } else {
            audioRecorder.record()
        }
    }
    
    @IBAction func stopButton(sender: AnyObject) {
        println("STOP RECORDING")
        audioRecorder.stop()
        

        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var getImagePath = paths.stringByAppendingPathComponent("recordTest.m4a")

        let data = NSData(contentsOfFile: getImagePath)
        
        var saveData = PFObject(className:"Audios")
        saveData.setValue(PFFile(data: data!), forKey: "audio")
        saveData.setValue("http://www.lanacion.com.ar/" + jsonPost["url"].stringValue, forKey: "url")
        saveData.setValue(Globals.user.username, forKey: "userID")
        
        saveData.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            if error != nil {
                println(error)
            }else {
                println(succeeded)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var error = NSErrorPointer()
        let player: AVAudioPlayer = AVAudioPlayer(data: audioJSON[indexPath.row], error: error)
        if error != nil {
            println(error)
        }
        player.delegate = self
        player.play()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return audioJSON.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DetailCollectionCell", forIndexPath: indexPath) as! DetailCollectionCell
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var ret:CGSize!
        
        let flowlayout = collectionViewLayout as! UICollectionViewFlowLayout
        ret = flowlayout.itemSize
        
        ret.width = 60
        ret.height = 60
        
        return ret
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}