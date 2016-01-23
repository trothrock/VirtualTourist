//
//  PinDetailViewController.swift
//  VirtualTourist
//
//  Created by Ted Rothrock on 1/21/16.
//  Copyright © 2016 Ted Rothrock. All rights reserved.
//

import UIKit
import MapKit

class PinDetailViewController: UIViewController {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    @IBOutlet weak var mapView: MKMapView!
    
    var pin: Pin? = nil
    
    //--------------------------------------
    // MARK: - Lifecycle
    //--------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMapPin()
        setMapProperties()
        if pin?.photos.count == 0 {
            FlickrClient.sharedInstance().getImagesFromFlickrForPin(pin!)
        }
    }
    
    //--------------------------------------
    // MARK: - MKMapView
    //--------------------------------------
    
    func setMapPin() {
        guard let pin = self.pin else {return}
        let region = MKCoordinateRegionMake(pin.coordinate, MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        mapView.region = region
        mapView.addAnnotation(pin)
    }
    
    func setMapProperties() {
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        mapView.pitchEnabled = false
        mapView.rotateEnabled = false
    }
}
