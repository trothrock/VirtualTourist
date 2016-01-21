//
//  Pin.swift
//  VirtualTourist
//
//  Created by Ted Rothrock on 1/20/16.
//  Copyright © 2016 Ted Rothrock. All rights reserved.
//

import Foundation
import MapKit

class Pin: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
