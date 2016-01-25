//
//  CustomCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Ted Rothrock on 1/23/16.
//  Copyright © 2016 Ted Rothrock. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
}
