//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Ted Rothrock on 1/20/16.
//  Copyright © 2016 Ted Rothrock. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    @IBOutlet weak var mapView: MKMapView!
    
    //--------------------------------------
    // MARK: - Lifecycle
    //--------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
    }
    
    //--------------------------------------
    // MARK: - Actions
    //--------------------------------------
    
    @IBAction func longPress(sender: UILongPressGestureRecognizer) {
        guard sender.state == UIGestureRecognizerState.Began else {return}
        let touchPoint: CGPoint = sender.locationInView(mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let newPin = Pin(coordinate: coordinate)
        print(newPin)
    }
    
    //--------------------------------------
    // MARK: - MKMapView Delegate
    //--------------------------------------
    
    
}

