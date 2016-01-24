//
//  PinDetailViewController.swift
//  VirtualTourist
//
//  Created by Ted Rothrock on 1/21/16.
//  Copyright © 2016 Ted Rothrock. All rights reserved.
//

import UIKit
import MapKit

class PinDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pin: Pin? = nil
    
    //--------------------------------------
    // MARK: - Lifecycle
    //--------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMapPin()
        setMapProperties()
        collectionView.delegate = self
        collectionView.dataSource = self
        if pin?.photos.count == 0 {
            FlickrClient.sharedInstance().getImagesFromFlickrForPin(pin!) { (success, errorString) in
                if success {
//                    self.collectionView.reloadData()
                } else {
                    print(errorString)
                }
            }
        } else {
//            self.collectionView.reloadData()
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
    
    //--------------------------------------
    // MARK: - UICollectionView
    //--------------------------------------
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pin!.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! CustomCollectionViewCell
        if let photoUrl = pin?.photos[indexPath.row].urlString {
            print(photoUrl)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
}
