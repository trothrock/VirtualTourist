//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Ted Rothrock on 1/22/16.
//  Copyright © 2016 Ted Rothrock. All rights reserved.
//

import Foundation
import CoreData
import SystemConfiguration

class FlickrClient: NSObject {

    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    let BASE_URL = "https://api.flickr.com/services/rest/"
    let METHOD_NAME = "flickr.photos.search"
    let API_KEY = "a655dfdf2cd37f0f64d5d0f22368062f"
    let PER_PAGE = "21"
    let EXTRAS = "url_m"
    let SAFE_SEARCH = "1"
    let DATA_FORMAT = "json"
    let NO_JSON_CALLBACK = "1"
    let BOUNDING_BOX_HALF_WIDTH = 1.0
    let BOUNDING_BOX_HALF_HEIGHT = 1.0
    let LAT_MIN = -90.0
    let LAT_MAX = 90.0
    let LON_MIN = -180.0
    let LON_MAX = 180.0
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    //--------------------------------------
    // MARK: - Connectivity
    //--------------------------------------
    
    func connectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        return (isReachable && !needsConnection)
    }
    
    //--------------------------------------
    // MARK: - Flickr API
    //--------------------------------------
    
    func getImagesFromFlickrForPin(pin: Pin, completionHandler: (errorString: String?) -> Void) {
        
        guard connectedToNetwork() else {
            completionHandler(errorString: "No network connection")
            return
        }
        
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "per_page": PER_PAGE,
            "page": String(pin.pageNumber),
            "bbox": createBoundingBoxStringForPin(pin),
            "safe_search": SAFE_SEARCH,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard error == nil else {
                completionHandler(errorString: error?.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Error code \(response.statusCode)")
                }
                completionHandler(errorString: "Error")
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request.")
                completionHandler(errorString: "Error")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                print("Unable to parse data as JSON: \(data)")
                completionHandler(errorString: "Error")
                return
            }
            
            guard let stat = parsedResult["stat"] as? String where stat == "ok" else {
                print("Flickr API returned an error. See error code and message in \(parsedResult)")
                completionHandler(errorString: "Error")
                return
            }
            
            guard let photosDictionary = parsedResult["photos"] as? NSDictionary else {
                print("Cannot find key 'photos' in \(parsedResult)")
                completionHandler(errorString: "Error")
                return
            }
            
            guard let totalPhotosVal = (photosDictionary["total"] as? NSString)?.integerValue else {
                print("Cannot find key 'total' in \(photosDictionary)")
                completionHandler(errorString: "Error")
                return
            }
            
            if totalPhotosVal > 0 {
                if let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] {
                    for photo in photosArray {
                        guard let urlString = photo["url_m"] as? String else {return}
                        let photoToAdd = Photo(urlString: urlString, context: self.sharedContext)
                        photoToAdd.pin = pin
                    }
                    CoreDataStackManager.sharedInstance().saveContext() { error in
                        if let _ = error {
                            completionHandler(errorString: "Unable to save")
                        }
                    }
                    completionHandler(errorString: nil)
                }
            } else {
                completionHandler(errorString: "No photos")
            }
        }
        
        task.resume()
    }
    
    func retrieveImageDataFromUrl(urlString: String, completionHandler: (imageData: NSData?, errorString: String?) -> Void) {
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            if let error = error {
                completionHandler(imageData: nil, errorString: error.localizedDescription)
            } else {
                completionHandler(imageData: data, errorString: nil)
            }
        }
        task.resume()
    }
    
    //--------------------------------------
    // MARK: - Helper functions
    //--------------------------------------
    
    func createBoundingBoxStringForPin(pin: Pin) -> String {
        let bottom_left_lon = max(pin.long - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(pin.lat - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(pin.long + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(pin.lat + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    func escapedParameters(parameters: [String: String]) -> String {
        var urlVars = [String]()
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlVars.append(key + "=" + "\(escapedValue!)")
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    //--------------------------------------
    // MARK: - Shared Instance
    //--------------------------------------
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}



