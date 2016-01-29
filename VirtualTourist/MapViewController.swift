//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Ted Rothrock on 1/20/16.
//  Copyright © 2016 Ted Rothrock. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, UIScrollViewDelegate {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var editingPins: Bool = false
    var selectedPin: Pin? = nil
    var pins = [Pin]()
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    //--------------------------------------
    // MARK: - Lifecycle
    //--------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        scrollView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        
        addSavedPinsToMap()
    }
    
    //--------------------------------------
    // MARK: - Add Saved Pins
    //--------------------------------------
    
    func addSavedPinsToMap() {
        pins = fetchAllPins()
        for pin in pins {
            mapView.addAnnotation(pin)
        }
    }
    
    func fetchAllPins() -> [Pin] {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
        } catch {
            print(error)
            return [Pin]()
        }
    }
    
    //--------------------------------------
    // MARK: - Actions
    //--------------------------------------
    
    @IBAction func longPress(sender: UILongPressGestureRecognizer) {
        
        // Pressing and holding a point on the map creates a new Pin object and adds it to the map.
        
        guard sender.state == UIGestureRecognizerState.Began else {return}
        let touchPoint: CGPoint = sender.locationInView(mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let newPin = Pin(lat: coordinate.latitude, long: coordinate.longitude, context: sharedContext)
        mapView.addAnnotation(newPin)
        CoreDataStackManager.sharedInstance().saveContext() {_ in}
    }
    
    @IBAction func editButtonPressed() {
        
        // Tapping the editButton scrolls the map up to reveal instructions. Tapping it again scrolls back.
        
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
    // MARK: - Navigation
    //--------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailViewController = segue.destinationViewController as! PinDetailViewController
        detailViewController.pin = selectedPin
    }
    
    //--------------------------------------
    // MARK: - MKMapView delegate
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
        
        // If user is in editing mode, delete pin. Otherwise, proceed to PinDetailViewController, passing the selected pin.
    
        if editingPins {
            if let view = view.annotation as? Pin {
                mapView.removeAnnotation(view)
                for photo in view.photos {
                    sharedContext.deleteObject(photo)
                }
                sharedContext.deleteObject(view)
                CoreDataStackManager.sharedInstance().saveContext() {_ in}
            }
        } else {
            if let view = view.annotation as? Pin {
                selectedPin = view
                self.performSegueWithIdentifier("showPinDetail", sender: nil)
            }
        }
    }
}

