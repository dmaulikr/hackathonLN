//
//  LastNewsCell.swift
//  hackathonLN
//
//  Created by f0go on 9/25/15.
//  Copyright (c) 2015 f0go. All rights reserved.
//

import Foundation
import UIKit

class LastNewsCell: UICollectionViewCell {
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryWidth: NSLayoutConstraint!
    @IBOutlet weak var categoryHeight: NSLayoutConstraint!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
}