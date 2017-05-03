//
//  HelperSharePlug.swift
//  TestApplication
//
//  Created by AzinecLLC on 4/5/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyJSON
import CoreLocation

class HelperSharePlug: NSObject{
    let currentUser = UserDefaults.standard
    
    
    func checkPlugSettings (duration : String, description: String, address: String, addressDetail : String, chargers : String) -> Bool {
        if duration == "" || description == "" || address == "" || addressDetail == "" || chargers == ""  {
            ShowAlertForAppDelegateNSObject().showAlert(text: "Please fill all the fields", controller: UIApplication.topViewController()!)
            return false
        }
        else if !validate(duration: duration) {
            ShowAlertForAppDelegateNSObject().showAlert(text: "You should write only numbers for maximum charging time", controller: UIApplication.topViewController()!)
            return false
        } 
        else {
            return true
        }
    }
    
    
    func setParamsForSharePlug (duration : String, description: String, address: String, addressDetail : String, chargers : String, locationLat : String, locationLong : String) -> [String : String]{
        var params : [String : String] = ["" : ""]
        
        let jsonFromLogin : JSON = HelperAlamofires().stringToJSON(self.currentUser.string(forKey: "loginJson")!)
        params = [
            "name": jsonFromLogin["data"]["userName"].stringValue + "'s spot",
            "duration": duration,
            "description": description,
            "address": address,
            "addressDetail": addressDetail,
            "location[0]": locationLat,
            "location[1]": locationLong 
        ]
        
        return params   
    }
    
    //check if characters in maximum charging time label are only numeric
    func validate(duration: String) -> Bool {
        let numberRegEx  = "^[0-9]+$"
        let texttest1 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        guard texttest1.evaluate(with: duration) else { return false }
        
        return true
    } 
    
    
    
}


