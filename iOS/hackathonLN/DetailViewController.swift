//
//  DetailViewController.swift
//  hackathonLN
//
//  Created by f0go on 9/25/15.
//  Copyright (c) 2015 f0go. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var holderHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryWidth: NSLayoutConstraint!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var noteHeight: NSLayoutConstraint!
    
    var postID: Int!
    
    override func viewDidLoad() {
        let url = NSURL(string: "http://contenidos.lanacion.com.ar/json/nota/\(postID)")
        Utils.makeJsonRequest(url!, callback: { (json, error) -> Void in
            if error != nil {
                println(error)
            }else {
                let imageURL = "http://bucket.lanacion.com.ar" + json["imagenes"][0]["src"].stringValue
                Utils.getImageFromUrl(imageURL, callback: { (image) -> Void in
                    self.image.image = image
                })
                
                self.titleLabel.text = json["titulo"]["valor"].stringValue
                self.categoryLabel.text = json["categoria"]["valor"].stringValue
                self.categoryLabel.sizeToFit()
                self.categoryWidth.constant = self.categoryLabel.frame.width + 30
                self.date.text = json["fecha"].stringValue
                self.note.text = self.parseContent(json["contenido"])
            }
        }, retryCount: 0)
    }
    
    func parseContent(JSON) -> String {
        var parsedContent: String!
        
        
        
        
        
        
        
        return parsedContent
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}