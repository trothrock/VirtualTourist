//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Ted Rothrock on 1/22/16.
//  Copyright © 2016 Ted Rothrock. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {

    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    let BASE_URL = "https://api.flickr.com/services/rest/"
    let METHOD_NAME = "flickr.photos.search"
    let API_KEY = "a655dfdf2cd37f0f64d5d0f22368062f"
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
    
    //--------------------------------------
    // MARK: - Flickr API
    //--------------------------------------
    
    func getImagesFromFlickrForPin(pin: Pin) {
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
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
                print("Error with request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Request returned an invalid response. Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Request returned an invalid response. Response: \(response)!")
                } else {
                    print("Request returned an invalid response.")
                }
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                print("Unable to parse data as JSON: \(data)")
            }
            
            // TODO: Handle parsed result.
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



