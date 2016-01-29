//
//  Photo.swift
//  VirtualTourist
//
//  Created by Ted Rothrock on 1/22/16.
//  Copyright © 2016 Ted Rothrock. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Photo: NSManagedObject {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    @NSManaged var urlString: String
    @NSManaged var pin: Pin?
    @NSManaged var imageData: NSData?
    var image: UIImage?
    
    //--------------------------------------
    // MARK: - Init Methods
    //--------------------------------------
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(urlString: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.urlString = urlString
    }
    
    func setPhotoImageWithData(data: NSData) {
        self.image = UIImage(data: data)
        let pngData = UIImagePNGRepresentation(self.image!)
        self.imageData = pngData!
    }
}
