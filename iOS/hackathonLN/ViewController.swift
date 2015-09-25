//
//  ViewController.swift
//  hackathonLN
//
//  Created by f0go on 9/25/15.
//  Copyright (c) 2015 f0go. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collection: UICollectionView!
    
    var lastNewsJSON: JSON = []
    
    override func viewDidLoad() {
        getLastNews()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        self.navigationController?.pushViewController(vc as DetailViewController, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lastNewsJSON.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LastNewsCell", forIndexPath: indexPath) as! LastNewsCell
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var ret:CGSize!
        
        let flowlayout = collectionViewLayout as! UICollectionViewFlowLayout
        ret = flowlayout.itemSize
        
        ret.width = Globals.screenSize.width
        ret.height = Globals.screenSize.height
            
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

