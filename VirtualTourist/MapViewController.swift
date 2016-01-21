//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Ted Rothrock on 1/20/16.
//  Copyright © 2016 Ted Rothrock. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, UIScrollViewDelegate {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var editingPins: Bool = false
    
    //--------------------------------------
    // MARK: - Lifecycle
    //--------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        scrollView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
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
    
    @IBAction func editButtonPressed() {
        if editingPins {
            editingPins = false
            editButton.title = "Edit"
            let attrs = [NSFontAttributeName: UIFont.systemFontOfSize(17)]
            editButton.setTitleTextAttributes(attrs, forState: UIControlState.Normal)
            let scrollPoint = CGPoint(x: 0.0, y: 0.0)
            scrollView.setContentOffset(scrollPoint, animated: true)
        } else {
            editingPins = true
            editButton.title = "Done"
            let attrs = [NSFontAttributeName: UIFont.boldSystemFontOfSize(17)]
            editButton.setTitleTextAttributes(attrs, forState: UIControlState.Normal)
            let scrollPoint = CGPoint(x: 0.0, y: 60.0)
            scrollView.setContentOffset(scrollPoint, animated: true)
        }
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
        if editingPins {
            // TODO: Delete pin.
            print("Delete pin")
        } else {
            // TODO: Segue to next view controller.
            print("Segue to next view controller")
        }
    }
}

