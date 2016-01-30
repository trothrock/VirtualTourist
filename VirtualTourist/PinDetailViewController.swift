//
//  PinDetailViewController.swift
//  VirtualTourist
//
//  Created by Ted Rothrock on 1/21/16.
//  Copyright © 2016 Ted Rothrock. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PinDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var noImagesLabel: UILabel!
    
    var pin: Pin? = nil
    var selectedCells = [NSIndexPath]()
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    //--------------------------------------
    // MARK: - Lifecycle
    //--------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMapPin()
        setMapProperties()
        
        // Configure collectionView.
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        collectionView.scrollEnabled = false
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
        
        // If this is a new pin, retrieve images from Flickr.
        
        if pin?.photos.count == 0 {
            FlickrClient.sharedInstance().getImagesFromFlickrForPin(pin!) { errorString in
                if let errorString = errorString {
                    self.handleErrorForString(errorString)
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    //--------------------------------------
    // MARK: - Actions
    //--------------------------------------
    
    @IBAction func bottomButtonTapped() {
        
        // Multi-purpose button. If no cells are selected and a network connection is available, retrieve a new set of images from Flickr. If cells are selected, delete them.
        
        if bottomButton.titleLabel!.text == "New collection" {
            
            guard FlickrClient.sharedInstance().connectedToNetwork() else {
                bottomButton.enabled = false
                showAlertController("No network connection", sender: bottomButton)
                return
            }
            
            // Disable ability to scroll until a new set of photos has been downloaded and displayed.
            
            collectionView.scrollEnabled = false
            
            // Increment the page number used in the Flickr API request and remove current photos from the pin.
            
            pin?.pageNumber += 1
            for photo in pin!.photos {
                photo.pin = nil
            }
            
            FlickrClient.sharedInstance().getImagesFromFlickrForPin(pin!) { errorString in
                if let errorString = errorString {
                    self.handleErrorForString(errorString)
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.collectionView.reloadData()
                    }
                }
            }
        } else {
            
            // Remove the selected cells from the pin.
            
            for index in 0...selectedCells.count - 1 {
                let cell = collectionView.cellForItemAtIndexPath(selectedCells[index]) as! CustomCollectionViewCell
                cell.photo!.pin = nil
            }
            
            // Delete the selected cells, clear the selectedCells array, and alter the title/function of the bottomButton.
            
            collectionView.deleteItemsAtIndexPaths(selectedCells)
            selectedCells.removeAll()
            bottomButton.setTitle("New collection", forState: UIControlState.Normal)
        }
    }
    
    //--------------------------------------
    // MARK: - MKMapView
    //--------------------------------------
    
    func setMapPin() {
        
        // Sets the pin location and zoom level of the mapView.
        
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
        
        // Appearance of selectedview is based on cell's "selected" status, not indexPath.
        
        if cell.selected {
            cell.selectedview.hidden = false
        } else {
            cell.selectedview.hidden = true
        }
        
        // Set the default cell configuration, a grey cell with a spinning activity indicator.
            
        cell.imageView.image = nil
        cell.defaultView.hidden = false
        cell.activityIndicator.hidesWhenStopped = true
        cell.activityIndicator.startAnimating()
        
        if let photo = pin?.photos[indexPath.row] {
            
            cell.photo = photo
            
            if photo.image != nil {
                
                // The image for the cell is still available.
                
                dispatch_async(dispatch_get_main_queue()) {
                    cell.activityIndicator.stopAnimating()
                    cell.defaultView.hidden = true
                    cell.imageView!.image = photo.image
                }
            } else if let imageData = photo.imageData {
                
                // The image has been downloaded in the past and the data saved.
                
                photo.image = UIImage(data: imageData)
                dispatch_async(dispatch_get_main_queue()) {
                    cell.activityIndicator.stopAnimating()
                    cell.defaultView.hidden = true
                    cell.imageView!.image = photo.image
                }
            } else {
                
                // No image or data exists for the cell. Download the image data from the photo's url.
                
                FlickrClient.sharedInstance().retrieveImageDataFromUrl(photo.urlString) { (data, errorString) in
                    if errorString != nil {
                        
                        // Unable to download data. Cell will remain a grey box. This allows the user to view previously downloaded photos even if all of the photos for a pin were not downloaded and saved in the past.
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.activityIndicator.stopAnimating()
                        }
                    } else {
                        if let data = data {
                            photo.setPhotoImageWithData(data)
                            dispatch_async(dispatch_get_main_queue()) {
                                cell.activityIndicator.stopAnimating()
                                cell.defaultView.hidden = true
                                cell.imageView!.image = photo.image
                            }
                            
                            // Scroll is disabled until all visible cells have loaded photos.
                            
                            if indexPath.row + 1 == collectionView.visibleCells().count {
                                collectionView.scrollEnabled = true
                            }
                        }
                    }
                }
            }
        } else {
            
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CustomCollectionViewCell
        
        // Obscure selected cells with a white, translucent view.
        
        cell.selectedview.hidden = false
        
        // Append all selected cells to an array and alter the title/function of the bottomButton.
        
        selectedCells.append(indexPath)
        if bottomButton.titleLabel!.text == "New collection" {
            bottomButton.setTitle("Remove selected pictures", forState: UIControlState.Normal)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CustomCollectionViewCell
        
        // Hide the white, translucent view.
        
        cell.selectedview.hidden = true
        
        // Remove the cell from the selectedCell array.
        
        let pathIndex = selectedCells.indexOf(indexPath)!
        selectedCells.removeAtIndex(pathIndex)
        
        // If this was the last selected cell, alter the title/function of the bottomButton.
        
        if selectedCells.count == 0 {
            bottomButton.setTitle("New collection", forState: UIControlState.Normal)
        }
    }
    
    //--------------------------------------
    // MARK: - Cell Sizing
    //--------------------------------------
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        // Regardless of orientation, cells should be 1/3 the width of the screen.
        
        let dimension = self.view.frame.size.width / 3.0
        return CGSizeMake(dimension, dimension)
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        // Invalidate collectionView layout before rotating so that cells will resize appropriately for the new orientation.
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    //--------------------------------------
    // MARK: - Error Handling
    //--------------------------------------
    
    func handleErrorForString(errorString: String) {
        if errorString == "No photos" {
            
            // The pin location has no associated Flickr photos.
            
            dispatch_async(dispatch_get_main_queue()) {
                self.noImagesLabel.hidden = false
            }
        } else {
            showAlertController(errorString, sender: nil)
        }
    }
    
    func showAlertController(errorString: String, sender: UIButton?) {
        
        var alertTitle = String()
        var alertMessage = String()
        
        switch errorString {
            
        case "No network connection":
            alertTitle = "No network connection"
            alertMessage = "You must be connected to the internet to access photos."
            
        default:
            alertTitle = "Error"
            alertMessage = errorString
        }
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) {
            (action) in
            if sender != self.bottomButton {
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        alert.addAction(okayAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
