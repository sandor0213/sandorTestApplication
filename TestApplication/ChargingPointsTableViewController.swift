//
//  ChargingPointsTableViewController.swift
//  TestApplication
//
//  Created by AzinecLLC on 3/28/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class ChargingPointsTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var sharePlugButton: UIButton!
    
    @IBOutlet weak var cancelRequestMainButton: UIButton!
    
    @IBOutlet weak var actualSpot: UIBarButtonItem!
    
    @IBOutlet weak var tableViewButton: UIBarButtonItem!
    
    
    let locationManager = CLLocationManager()
    var meCoordinates = CLLocationCoordinate2D()
    var chargingPointsArrayWithDistancesSorted = [(String, Double, JSON)]()
    var myLocationArray : [CLLocationCoordinate2D] = []
    var indexOfRow = 0
    var resultArray = [JSON]()
    let currentUser = UserDefaults.standard
    var selectedRow : Bool = false
    var reload = true
    
    override func viewDidLoad() {
        
        locationManager.delegate = self
        self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.cancelRequestMainButton.isHidden = true
        
        self.navigationItem.setHidesBackButton(true, animated:true)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.isToolbarHidden = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.userLocation), name: NSNotification.Name(rawValue: "unplagged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelButtonHiddenWhenStartedCharging), name: NSNotification.Name(rawValue: "startCharge"), object: nil)
        
        
        HelperAlamofires().getPrivateSpotList { (responsejson) in
            self.resultArray = responsejson
            self.locationManager.startUpdatingLocation() 
        }
        
        super.viewDidLoad()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestAlwaysAuthorization()
        }
        else if CLLocationManager.authorizationStatus() == .denied {  
            ShowAlertForAppDelegateNSObject().showAlert(text: "To find/create a plug, you should allow geolocation usage by the program", controller: self)
        } 
        else if CLLocationManager.authorizationStatus() == .authorizedAlways {
        }
    }
    
    
    
    func userLocation(){
        locationManager.startUpdatingLocation() 
    }
    
    
    func loadList(){        
        locationManager.startUpdatingLocation()
    }
    
    func cancelButtonHiddenWhenStartedCharging (){
        self.cancelRequestMainButton.isHidden = true
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        meCoordinates = (manager.location?.coordinate)!
        
        if self.myLocationArray.count == 0{
            self.myLocationArray.append(meCoordinates)
        } else {
            self.myLocationArray[0] = meCoordinates
        }
        
        self.locationManager.stopUpdatingLocation()
        
        let userLocationLatitude = Double("\(self.meCoordinates.latitude)")!
        let userLocationLongitude = Double("\(self.meCoordinates.longitude)")!
        
        currentUser.set(userLocationLatitude, forKey: "userLocationLatitude")
        currentUser.set(userLocationLongitude, forKey: "userLocationLongitude")
        
        HelperAlamofires().getJsonFromGoogleDirectionApi(myLocationArray: self.myLocationArray, chargingPointsArray: self.resultArray) { (chargingPointsArrayWithDistancesSorted) in
            self.chargingPointsArrayWithDistancesSorted = chargingPointsArrayWithDistancesSorted
            
            self.currentUser.set("\(self.myLocationArray[0].latitude)", forKey: "userLatitude")
            self.currentUser.set("\(self.myLocationArray[0].longitude)", forKey: "userLongitude")
            
            self.tableView.reloadData()
        }              
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chargingPointsArrayWithDistancesSorted.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customcell", for: indexPath) as! ChargingTableViewCell
        
        if self.chargingPointsArrayWithDistancesSorted.count > 0 {
            
            cell.setUp(name: "\(self.chargingPointsArrayWithDistancesSorted[indexPath.row].2["name"])", distance: "\(self.chargingPointsArrayWithDistancesSorted[indexPath.row].0)", address: "\(self.chargingPointsArrayWithDistancesSorted[indexPath.row].2["address"])", tableView: self)
            
            
            cell.chargingPointaddressLabel.adjustsFontSizeToFitWidth = true
            cell.spotId = "\(self.chargingPointsArrayWithDistancesSorted[indexPath.row].2["_id"])"
            
            // crutch for google Api Direction
            cell.chargingPointsArrayWithDistancesSortedForDetails = chargingPointsArrayWithDistancesSorted[indexPath.row]
            // crutch for google Api Direction END
            
            
            if self.currentUser.bool(forKey: "ownerOfSpot"){
                self.cancelRequestMainButton.isHidden = true
                cell.sendRequestForCharge.isHidden = true
                cell.cancelRequestForChargingFromSenderButton.isHidden = true
                if cell.spotId == self.currentUser.string(forKey: "createdSpotID")!{
                } 
            } else {
                
                if self.currentUser.bool(forKey: "sendedRequest"){
                    self.cancelRequestMainButton.isHidden = false
                    cell.sendRequestForCharge.isHidden = true
                    
                    if cell.spotId == self.currentUser.string(forKey: "selectedSpotId")!{
                        cell.cancelRequestForChargingFromSenderButton.isHidden = false
                    } else {
                        cell.cancelRequestForChargingFromSenderButton.isHidden = true
                    }
                    
                } else {
                    cell.sendRequestForCharge.isHidden = false
                    self.cancelRequestMainButton.isHidden = true    
                    cell.cancelRequestForChargingFromSenderButton.isHidden = true  
                }
            }
            
            if self.currentUser.bool(forKey: "startedChargeInSelectedSpot"){
                self.cancelRequestMainButton.isHidden = true
                cell.cancelRequestForChargingFromSenderButton.isHidden = true
            }
        }
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.indexOfRow = indexPath.row
        self.selectedRow = true
        var cell = tableView.cellForRow(at: indexPath)
        
        self.performSegue(withIdentifier: "fromChargingPointsTableViewControllerToDetailsChargingPointViewController", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromChargingPointsTableViewControllerToDetailsChargingPointViewController" {
            let destination = segue.destination as! DetailsChargingPointViewController
            if self.selectedRow{
                destination.chargingPointsArrayWithDistancesSortedForDetails = self.chargingPointsArrayWithDistancesSorted[self.indexOfRow] 
            }
        }
    }
    
    
    
    @IBAction func CanceledPrivateHostRequest(_ sender: Any) {
        HelperAlamofires().putCanceledPrivateHostRequestBeforeConfirmation(userId: currentUser.string(forKey: "userid")!, historyId: self.currentUser.string(forKey: "historyIdWhenSendRequestForAplug")!) { (status, rejson) in
            if status{
                ShowAlertForAppDelegateNSObject().showAlert(text: "You had succesfully cancel your request", controller: UIApplication.topViewController()!)
            }
            
            self.locationManager.startUpdatingLocation()
        }
    }
    
    
    
    
    @IBAction func reloadSpots(_ sender: Any) {
        self.locationManager.startUpdatingLocation()
    }
    
    
    
    
    @IBAction func sharePlugAction(_ sender: Any) {
        
        if self.currentUser.bool(forKey: "sendedRequest") {
            ShowAlertForAppDelegateNSObject().showAlert(text: "First you must cancel the previous request to create a spot", controller: self)
        } else if self.currentUser.bool(forKey: "ownerOfSpot"){ 
            ShowAlertForAppDelegateNSObject().showAlert(text: "User can be owner only one spot", controller: self)
        } else {
            self.performSegue(withIdentifier: "fromChargingPointsTableViewControllerToSharePlugSettingsViewController", sender: self)
        }
    }
    
    
    @IBAction func showActualSpot(_ sender: Any) {
        if self.currentUser.bool(forKey: "ownerOfSpot") || self.currentUser.bool(forKey: "sendedRequest"){
            self.performSegue(withIdentifier: "fromChargingPointsTableViewControllerToDetailsChargingPointViewController", sender: self)
        } else {
            ShowAlertForAppDelegateNSObject().showAlert(text: "You are not send request for charge and you haven't own spot", controller: self)
        }
    }
    
    
    
    
}


