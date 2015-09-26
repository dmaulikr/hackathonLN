//
//  ViewController.swift
//  hackathonLN
//
//  Created by f0go on 9/25/15.
//  Copyright (c) 2015 f0go. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collection: UICollectionView!
    
    var lastNewsJSON: JSON = []
    
    override func viewDidLoad() {
        getLastNews()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
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
        
        cell.backImage.image = nil
        
        if lastNewsJSON[indexPath.row]["imagenes"].count > 0 {
            let imageURL = "http://bucket.lanacion.com.ar" + lastNewsJSON[indexPath.row]["imagenes"][0]["src"].stringValue
            println("imageURL: \(imageURL)")
            Utils.getImageFromUrl(imageURL, callback: { (image) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if let cellToUpdate = collectionView.cellForItemAtIndexPath(indexPath) {
                        let blur = image.applyBlurWithRadius(15, blurType: BOXFILTER, tintColor: UIColor.clearColor(), saturationDeltaFactor: 1, maskImage: nil)
                        cell.backImage.image = blur
                    }
                })
            })
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

}

