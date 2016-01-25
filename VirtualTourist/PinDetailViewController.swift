//
//  PinDetailViewController.swift
//  VirtualTourist
//
//  Created by Ted Rothrock on 1/21/16.
//  Copyright © 2016 Ted Rothrock. All rights reserved.
//

import UIKit
import MapKit

class PinDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
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
        
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
        
        if pin?.photos.count == 0 {
            FlickrClient.sharedInstance().getImagesFromFlickrForPin(pin!) { (success, errorString) in
                if let errorString = errorString {
                    print(errorString)
                    // TODO: Handle error
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.collectionView.reloadData()
                    }
                }
            }
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
        
        cell.imageView.image = nil
        cell.defaultView.hidden = false
        cell.activityIndicator.hidesWhenStopped = true
        cell.activityIndicator.startAnimating()
        
        if let photo = pin?.photos[indexPath.row] {
            FlickrClient.sharedInstance().taskToRetrieveImageDataFromUrl(photo.urlString) { (data, errorString) in
                if let errorString = errorString {
                    print(errorString)
                    // TODO: Handle error.
                } else {
                    if let data = data {
                        let image = UIImage(data: data)
                        photo.image = image
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.activityIndicator.stopAnimating()
                            cell.defaultView.hidden = true
                            cell.imageView!.image = photo.image
                        }
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    //--------------------------------------
    // MARK: - Cell Sizing
    //--------------------------------------
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let dimension = self.view.frame.size.width / 3.0
        return CGSizeMake(dimension, dimension)
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
}
