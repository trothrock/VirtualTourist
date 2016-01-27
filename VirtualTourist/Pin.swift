//
//  Pin.swift
//  VirtualTourist
//
//  Created by Ted Rothrock on 1/20/16.
//  Copyright © 2016 Ted Rothrock. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class Pin: NSManagedObject, MKAnnotation {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    @NSManaged var lat: Double
    @NSManaged var long: Double
    @NSManaged var photos: [Photo]
    @NSManaged var pageNumber: Int
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    //--------------------------------------
    // MARK: - Init Methods
    //--------------------------------------
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(lat: Double, long: Double, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.lat = lat
        self.long = long
        self.pageNumber = 1
    }
}
