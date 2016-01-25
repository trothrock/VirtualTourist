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
}
