//
//  HelperMyLocationDistance.swift
//  TestApplication
//
//  Created by AzinecLLC on 4/14/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit
import CoreLocation

class HelperMyLocationDistance: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var userCoordinates = CLLocationCoordinate2D()
    let currentUser = UserDefaults.standard
  
    
    func notificationLocation(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "unplagged"), object: nil)
    }
    
    func distanceFromUserLocationToSpot () -> Bool{

        
        let userLocationlatitude = currentUser.double(forKey: "userLocationLatitude")
        let userLocationLongitude = currentUser.double(forKey: "userLocationLongitude")
        
        
        if self.currentUser.object(forKey: "currentSpotLatitude") != nil && self.currentUser.object(forKey: "currentSpotLongitude") != nil {
            let differenceLatitude = userLocationlatitude - Double(self.currentUser.string(forKey: "currentSpotLatitude")!)!
            let differenceLongitude = userLocationLongitude - Double(self.currentUser.string(forKey: "currentSpotLongitude")!)!

            let distanceInMeters = sqrt(pow(differenceLatitude, 2)  + pow(differenceLongitude, 2)) * 100000
            locationManager.stopUpdatingLocation()
            
            if distanceInMeters <= 50{

                
                return true
            }
        }
        return false
    }
    
    
    func distanceForReloadChargingPointsTableView (newCoordinates : CLLocationCoordinate2D) -> Bool {
        let userLocationlatitude = currentUser.double(forKey: "userLocationLatitude")
        let userLocationLongitude = currentUser.double(forKey: "userLocationLongitude")
        
       
           
        let differenceLatitude = userLocationlatitude - newCoordinates.latitude
        let differenceLongitude = userLocationLongitude - newCoordinates.longitude
        let distanceInMeters = sqrt(pow(differenceLatitude, 2) + pow(differenceLongitude, 2)) * 100000
        
        if distanceInMeters >= 20{
            
            return true
            }
        
    return false    
    
}
    
}
