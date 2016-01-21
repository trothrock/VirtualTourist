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
        mapView.addAnnotation(newPin)
    }
    
    //--------------------------------------
    // MARK: - MKMapView Delegate
    //--------------------------------------
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Pin {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequedView.annotation = annotation
                view = dequedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.animatesDrop = true
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("Annotation view selected")
    }
}

