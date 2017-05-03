//
//  SharePlugSettingsViewController.swift
//  TestApplication
//
//  Created by AzinecLLC on 4/10/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

class SharePlugSettingsViewController: UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var sharePlugSettingsButton: UIButton!
    
    @IBOutlet weak var localizeAddressButton: UIButton!
    
    @IBOutlet weak var addressTextView: UITextView!
    
    @IBOutlet weak var chargersTextField: UITextField!
    
    @IBOutlet weak var maximumChargingTimeTextfield: UITextField!
    
    @IBOutlet weak var chargingConditionsTextView: UITextView!
    
    @IBOutlet weak var adrressDetailsTextView: UITextView!
    
    @IBOutlet weak var findPlugButton: UIButton!
    
    @IBOutlet weak var forFrameView: UIView!
    
    let locationManager = CLLocationManager()
    
    var userCoordinates = CLLocationCoordinate2D()
    
    let currentUser = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.navigationItem.setHidesBackButton(true, animated:true)
        self.navigationController?.isToolbarHidden = true
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "forFrameViewTapped")
        self.forFrameView.addGestureRecognizer(tapGesture)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestAlwaysAuthorization()
        }
        else if CLLocationManager.authorizationStatus() == .denied {  
            ShowAlertForAppDelegateNSObject().showAlert(text: "To find/create a plug, you should allow geolocation usage by the program", controller: self)
        } 
        else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func forFrameViewTapped() {
        self.view.endEditing(true)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userCoordinates = (manager.location?.coordinate)!
    }
    
    
    @IBAction func LocalizaAddressAction(_ sender: Any) {
        locationManager.startUpdatingLocation()
        HelperAlamofires().localizeMyAddress(userCoordinates: self.userCoordinates) { (address) in
            self.addressTextView.text = address
        }
    }
    
    
    
    @IBAction func sharePlugSettingsAction(_ sender: Any) {
        if HelperSharePlug().checkPlugSettings(duration: self.maximumChargingTimeTextfield.text!, description: self.chargingConditionsTextView.text!, address: self.addressTextView.text!, addressDetail: self.adrressDetailsTextView.text!, chargers: self.chargersTextField.text!){
            
            HelperAlamofires().getMyLocationCoordinates(address: self.addressTextView.text!) { (status, locationLat, locationLong) in
                
                if status {
                    
                    let params = HelperSharePlug().setParamsForSharePlug(duration: self.maximumChargingTimeTextfield.text!, description: self.chargingConditionsTextView.text!, address: self.addressTextView.text!, addressDetail: self.adrressDetailsTextView.text!, chargers: self.chargersTextField.text!, locationLat: "\(locationLat)", locationLong: "\(locationLong)")
                    
                    
                    HelperAlamofires().postCreatePrivateChargerPoint(params: params, hostId: self.currentUser.string(forKey: "userid")!) { (status, responenseJson) in
                    }
                }
            }
        }
    }
    
    
    
    @IBAction func goToChargingPointsTableViewController(_ sender: Any) {
        self.navigationController?.performSegue(withIdentifier: "toChargingPointsTable", sender: self.navigationController)
    } 
}
