//
//  HelperAlamofires.swift
//  TestApplication
//
//  Created by AzinecLLC on 4/3/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import JWT
import CoreLocation
import ReachabilitySwift

class HelperAlamofires: NSObject, CLLocationManagerDelegate {
    let urlBasic : String = "http://188.166.110.248"
    let port : String = "3010"
    var token : String = "1"
    let currentUser = UserDefaults.standard
    let reachability = Reachability()!
    
    
    func noInternetConnection(){
        ShowAlertForAppDelegateNSObject().showAlert(text: "Make sure your device is connected to the internet", controller: UIApplication.topViewController()!)
    }
    
    
    
    // ***Login
    func login (loginparams : [String: String], completitionHandler : @escaping (_ status : Bool, _ loginJson : JSON, _ responseString : String) -> ()) {
        var responseString = ""
        
        Alamofire.request("\(self.urlBasic):\(self.port)/v1/users/login/manual", method: .post, parameters: loginparams).responseJSON { (response) in
            
            let loginJson : JSON = JSON(response.data)
            
            if loginJson["description"].stringValue == "OK" {
                
                self.currentUser.set(true, forKey: "isLogined")
                self.currentUser.set("\(loginJson)", forKey: "loginJson")
                self.currentUser.set(loginJson["data"]["_id"].stringValue, forKey: "userid")
                
                completitionHandler (true, loginJson, "")
                
            } else {
                switch loginJson["error"].stringValue{
                case "Account doesn't exist" : responseString = "Such username doesn't exist"
                case "Incorrect password" : responseString = "Incorrect password"
                    
                default : break
                }
                
                completitionHandler (false, loginJson, responseString)
            }
        }   
    }
    
    
    
    
    // ***Registration
    
    func registration (regparams : [String : String], completitionHandler : @escaping (_ status : Bool, _ registrationJson : JSON, _ responseString : String) -> ()) {
        var responseString = ""
        
        Alamofire.request("\(self.urlBasic):\(self.port)/v1/users", method: .post, parameters: regparams).responseJSON { (response) in
            
            let registrationJson : JSON = JSON(response.data)
            
            if registrationJson["description"].stringValue == "Created" {
                
                completitionHandler (true, registrationJson, "")
                
            } else {
                if registrationJson["error"]["errors"]["userName"]["message"].stringValue == "Error, expected `userName` to be unique. Value: `\(regparams["userName"]!)`"{
                    responseString = "Username is already taken"
                } else if registrationJson["error"].stringValue == "Email already in use"{
                    responseString = "Email is already taken"      
                }
                
                completitionHandler (false, registrationJson, responseString)
            }
        }   
    }
    
    
    
    //***get private spot list
    
    func getPrivateSpotList(completitionHandler: @escaping (_ response: [JSON]) -> ()){
        
        guard reachability.isReachable else {
            self.noInternetConnection()
            return  
        }
        
        Alamofire.request("\(self.urlBasic):\(self.port)/v1/private-spots?token=\(self.token)", method: .get).responseJSON { (response) in
            let json : JSON = JSON(response.data)
            var resultArray = json["data"].arrayValue
            completitionHandler(resultArray)
        }        
    }
    
    
    
    
    // ***for ChargingPointsTableViewController
    func getJsonFromGoogleDirectionApi(myLocationArray : [CLLocationCoordinate2D], chargingPointsArray : [JSON], completitionHandler: @escaping (_ chargingPointsArrayWithDistancesSorted : [(String, Double,JSON)]) -> ()) {
        
        guard reachability.isReachable else {
            self.noInternetConnection()
            return  
        }
        
        let maxDistanceFromSettings = 2000
        var chargingPointsArray = chargingPointsArray
        var chargingPointsArrayWithDistancesSorted = [(String, Double, JSON)]()
        var distanceDroppedDouble : Double = 0.0
        let myLocationString : String = "\(myLocationArray[0].latitude),\(myLocationArray[0].longitude)"
        
        for item in chargingPointsArray{
            if item["owner"] != nil {
                let chargingPointLocationString = "\(item["location"][0].stringValue),\(item["location"][1].stringValue)"
                Alamofire.request("https://maps.googleapis.com/maps/api/directions/json?origin=\(myLocationString)&destination=\(chargingPointLocationString)&sensor=true&mode=walking&language=en&key=AIzaSyBxPYWsHOjNoqP2VoML6NuBFujn5mF2F14", method: .get).responseJSON { (response) in
                    
                    let json : JSON = JSON(response.data)
                    
                    if json["status"].stringValue == "OK"{
                        
                        let distance = json["routes"][0]["legs"][0]["distance"]["text"].stringValue
                        
                        var distanceDropped = String(distance.characters.dropLast(1))
                        
                        if distanceDropped.characters.last == "k" {
                            distanceDropped = String(distanceDropped.characters.dropLast(2))
                            distanceDroppedDouble = Double(distanceDropped)! * 1000
                        } else {
                            distanceDropped = String(distanceDropped.characters.dropLast(1)) 
                            distanceDroppedDouble = Double(distanceDropped)!  
                        }
                        
                        
                        if distanceDroppedDouble <= Double(maxDistanceFromSettings){
                            chargingPointsArrayWithDistancesSorted.append((distance, distanceDroppedDouble, item))
                        }
                        
                        if item["owner"]["_id"].stringValue == self.currentUser.string(forKey: "userid")!{
                            self.currentUser.set(distance, forKey: "currentSpotDistance")
                            self.currentUser.set("\(item)", forKey: "currentSpotJson")
                        }
                        else if self.currentUser.bool(forKey: "sendedRequest") {
                            if item["_id"].stringValue == self.currentUser.string(forKey: "selectedSpotId")!{
                                
                                self.currentUser.set(distance, forKey: "currentSpotDistance")
                                self.currentUser.set("\(item)", forKey: "currentSpotJson")
                            }
                        }
                    } 
                    
                    chargingPointsArrayWithDistancesSorted = chargingPointsArrayWithDistancesSorted.sorted{
                        return $0.1 < $1.1}           
                    
                    completitionHandler (chargingPointsArrayWithDistancesSorted) 
                } 
            } 
        } 
    }
    
    
    
    
    
    //*** send request for a private spot
    func postSendRequestForAplug(userLat: String, userLong : String, spotId : String ,completitionHandler: @escaping (_ status : Bool, _ response: JSON) -> ()){
        
        guard reachability.isReachable else {
            self.noInternetConnection()
            return  
        }
        
        let loginJson = self.currentUser.string(forKey: "loginJson")
        
        let json : JSON = stringToJSON(loginJson!)
        
        let userid = json["data"]["_id"].stringValue
        
        let params: [String:String] = [
            "spot"          : spotId,
            "location[0]"   : userLat,
            "location[1]"   : userLong
        ] 
        
        Alamofire.request("\(self.urlBasic):\(self.port)/v1/users/\(userid)/private-history?token=\(self.token)", method: .post, parameters: params).responseJSON { (response) in
            let json : JSON = JSON(response.data)
            
            if json["code"].stringValue == "200" {
                self.currentUser.set(true, forKey: "sendedRequest")
                self.currentUser.set(json["data"]["spot"]["name"].stringValue, forKey: "spotName")
                self.currentUser.set(json["data"]["spot"]["_id"].stringValue, forKey: "selectedSpotId")
                self.currentUser.set(json["data"]["_id"].stringValue, forKey: "historyIdWhenSendRequestForAplug")
                self.currentUser.set(json["data"]["spot"]["location"][0].stringValue, forKey: "currentSpotLatitude")
                self.currentUser.set(json["data"]["spot"]["location"][1].stringValue, forKey: "currentSpotLongitude")
                ShowAlertForAppDelegateNSObject().showAlert(text: "You succesfully send request for \(self.currentUser.string(forKey: "spotName")!)", controller: UIApplication.topViewController()!)
                completitionHandler(true, json)
                
            } else if json["error"] == "You should to complete previous session"{
                ShowAlertForAppDelegateNSObject().showAlert(text: "You should to complete previous session at \(self.currentUser.string(forKey: "spotName")!)", controller: UIApplication.topViewController()!)
            }
        }
    }
    
    //***convert string to JSON
    func stringToJSON(_ jsonString:String) -> JSON {
        do {
            if let data:Data = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false){
                if jsonString != "error" {
                    let jsonResult:JSON = JSON(data: data)
                    return jsonResult
                }
            }
        }
        catch _ as NSError {
            
        }
        
        return nil
    }
    
    
    //***cancel request from private spot before confirmation
    func putCanceledPrivateHostRequestBeforeConfirmation(userId:String, historyId:String, completitionHandler: @escaping (_ status : Bool, _ response: JSON) -> ()){
        
        guard reachability.isReachable else {
            self.noInternetConnection()
            return  
        }
        
        Alamofire.request("\(self.urlBasic):\(self.port)/v1/users/\(userId)/private-history/\(historyId)/canceled-before-confirmation?token=\(self.token)", method: .put, parameters: nil).responseJSON { (response) in
            let json = JSON(response.data)
            if json["code"].stringValue == "200"{  
                self.currentUser.set(false, forKey: "sendedRequest")
                self.currentUser.set(nil, forKey: "spotName")
                self.currentUser.set(nil, forKey: "selectedSpotId")
                self.currentUser.set(nil, forKey: "historyIdWhenSendRequestForAplug")
                self.currentUser.set(nil, forKey: "currentSpotLatitude")
                self.currentUser.set(nil, forKey: "currentSpotLongitude")
                completitionHandler(true, json)    
            }
        }
    }
    
    
    //***create private spot
    func postCreatePrivateChargerPoint(params:[String:String], hostId:String, completitionHandler: @escaping (_ status:Bool, _ spot:JSON) -> ()){
        
        guard reachability.isReachable else {
            self.noInternetConnection()
            return  
        }
        
        Alamofire.request("\(self.urlBasic):\(self.port)/v1/users/\(hostId)/spots?token=\(self.token)", method: .post, parameters: params).responseJSON { (response) in
            let json = JSON(response.data)
            
            if json["description"].stringValue == "Created"{
                self.currentUser.set(true, forKey: "ownerOfSpot")
                self.currentUser.set(json["data"]["_id"].stringValue, forKey: "createdSpotID")
                ShowAlertForAppDelegateNSObject().showAlertemptyTextAndPerformSegue(text: "Creating the spot was succesfull", controller: UIApplication.topViewController()!, identifier: "toDetailsChargingPointViewController")
                completitionHandler (true, json)
                
            } else {
                completitionHandler (false, json)
                switch json["error"].stringValue{
                case  "This location already reserved" : ShowAlertForAppDelegateNSObject().showAlert(text: "This location already reserved", controller: UIApplication.topViewController()!)
                default : break
                }
            }
        }
    }
    
    
    
    //***remove private Spot
    func deleteRemovePrivateSpot(completitionHandler: @escaping (_ status : Bool, _ Json : JSON, _ respensetext : String) -> ()){
        
        guard reachability.isReachable else {
            self.noInternetConnection()
            return  
        }
        
        if self.currentUser.bool(forKey: "ownerOfSpot"){
            let createdSpotID = self.currentUser.string(forKey: "createdSpotID")!
            
            Alamofire.request("\(self.urlBasic):\(self.port)/v1/users/\(currentUser.string(forKey: "userid")!)/spots/\(createdSpotID)/?token=\(self.token)", method: .delete).responseJSON(completionHandler: { (response) in
                let json = JSON(response.data)
                if json["description"].stringValue == "OK"{
                    self.currentUser.set(false, forKey: "ownerOfSpot")
                    
                    if self.currentUser.bool(forKey: "isLogined"){
                        ShowAlertForAppDelegateNSObject().showAlertemptyTextAndPerformSegue(text: "Deleting the spot was succesful", controller: UIApplication.topViewController()!, identifier: "toChargingPointsTable")
                    }
                    completitionHandler(true, json, "")
                    
                } else {
                    completitionHandler (false, json, "")
                    
                    switch json["error"].stringValue{
                    case "Deleting a charge was failed" : ShowAlertForAppDelegateNSObject().showAlert(text: "Deleting the spot was failed", controller: UIApplication.topViewController()!)
                    case "You are not owner of this spot" : ShowAlertForAppDelegateNSObject().showAlert(text: "You are not owner of this spot", controller: UIApplication.topViewController()!)
                        
                    default : break
                    }        
                } 
            })
        }
    }
    
    
    //***convert coordinate to address
    func localizeMyAddress(userCoordinates : CLLocationCoordinate2D, completitionHandler : @escaping (_ address : String) -> ()) {
        
        guard reachability.isReachable else {
            self.noInternetConnection()
            return  
        }
        
        let userCoordinatesString : String = "\(userCoordinates.latitude),\(userCoordinates.longitude)"
        
        Alamofire.request("https://maps.googleapis.com/maps/api/geocode/json?latlng=\(userCoordinatesString)&language=en&key=AIzaSyCowiDuW-atJSKwh5jSPNU0J5VeR9bQW70", method: .get).responseJSON { (response) in
            let json : JSON = JSON(response.data)
            let address = json["results"][0]["formatted_address"].stringValue
            completitionHandler (address) 
        }
    }
    
    
    
    
    
    //***convert address to coordinate
    func getMyLocationCoordinates (address: String, completitionHandler : @escaping (_ status : Bool, _ locationLat : String, _ locationLong : String) -> ()) {
        
        guard reachability.isReachable else {
            self.noInternetConnection()
            return  
        }
        
        Alamofire.request("https://maps.googleapis.com/maps/api/geocode/json?address=\(address)&key=AIzaSyBxPYWsHOjNoqP2VoML6NuBFujn5mF2F14".replacingOccurrences(of: " ", with: "%20"), method: .get).responseJSON { (response) in
            let json : JSON = JSON(response.data)
            
            if json["status"].stringValue == "OK"{
                let locationLat = json["results"][0]["geometry"]["location"]["lat"].stringValue
                let locationLong = json["results"][0]["geometry"]["location"]["lng"].stringValue
                completitionHandler (true, locationLat, locationLong)
                
            } else {
                ShowAlertForAppDelegateNSObject().showAlert(text: "Incorrect address", controller: UIApplication.topViewController()!)
            } 
            completitionHandler (false, "", "")
        }
    }
    
    
    
}







