//
//  DetailsChargingPointViewController.swift
//  TestApplication
//
//  Created by AzinecLLC on 4/20/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON

class DetailsChargingPointViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var chargersLabel: UILabel!
    
    @IBOutlet weak var maximumChargingTimeLabel: UILabel!
    
    @IBOutlet weak var chargingConditionsTextview: UITextView!
    
    @IBOutlet weak var adrressDetailsTextview: UITextView!
    
    @IBOutlet weak var chargeButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var removeSpotButton: UIButton!
    
    @IBOutlet weak var listButton: UIBarButtonItem!
    
    let currentUser = UserDefaults.standard
    
    var chargingPointsArrayWithDistancesSortedForDetails : (String, Double, JSON) = ("", 0.0, JSON("")) 
    
    
    override func viewDidLoad() {
        self.navigationController?.isToolbarHidden = true        
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        if self.chargingPointsArrayWithDistancesSortedForDetails == ("", 0.0, JSON("")) {
            let selectedSpotDistanceJson : JSON = HelperAlamofires().stringToJSON(self.currentUser.string(forKey: "currentSpotJson")!)
            self.chargingPointsArrayWithDistancesSortedForDetails = (self.currentUser.string(forKey: "currentSpotDistance")!, 0.0, selectedSpotDistanceJson)             
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeButtonHiddenSettings), name: NSNotification.Name(rawValue: "load"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelButtonHiddenWhenStartedCharging), name: NSNotification.Name(rawValue: "startCharge"), object: nil)
        
        
        // check which button can be used
        if self.currentUser.bool(forKey: "ownerOfSpot"){
            self.chargeButton.isHidden = true
            self.cancelButton.isHidden = true
            self.removeSpotButton.isHidden = false
            
        } else if self.currentUser.bool(forKey: "sendedRequest"){
            if self.chargingPointsArrayWithDistancesSortedForDetails.2["_id"].stringValue == self.currentUser.string(forKey: "selectedSpotId")! {         
                self.chargeButton.isHidden = true
                self.cancelButton.isHidden = false
                self.removeSpotButton.isHidden = true
                
            } else {
                self.chargeButton.isHidden = true
                self.cancelButton.isHidden = true
                self.removeSpotButton.isHidden = true
            }
            
        } else {
            self.chargeButton.isHidden = false
            self.cancelButton.isHidden = true
            self.removeSpotButton.isHidden = true
        }
        
        if self.currentUser.bool(forKey: "startedChargeInSelectedSpot"){ 
            self.cancelButton.isHidden = true
        }
        // check which button can be used End
        
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        // set up plug details
        self.nameLabel.text = self.chargingPointsArrayWithDistancesSortedForDetails.2["name"].stringValue
        self.distanceLabel.text = self.chargingPointsArrayWithDistancesSortedForDetails.0
        self.addressLabel.text = self.chargingPointsArrayWithDistancesSortedForDetails.2["address"].stringValue
        self.chargersLabel.text = HelperDetailsChargingPointViewController().getChargerTypesFromArrayToString(chargerTypesArray: self.chargingPointsArrayWithDistancesSortedForDetails.2["chargerTypes"].arrayValue)
        self.maximumChargingTimeLabel.text = self.chargingPointsArrayWithDistancesSortedForDetails.2["duration"].stringValue
        self.chargingConditionsTextview.text = self.chargingPointsArrayWithDistancesSortedForDetails.2["condition"].stringValue
        self.adrressDetailsTextview.text = self.chargingPointsArrayWithDistancesSortedForDetails.2["addressDetail"].stringValue
        // set up plug details End
    }
    
    
    
    // when unplagged
    func changeButtonHiddenSettings(){
        self.chargeButton.isHidden = false
        self.cancelButton.isHidden = true
    }
    // when unplagged End
    
    
    func cancelButtonHiddenWhenStartedCharging(){
        self.cancelButton.isHidden = true
    }
    
    
    @IBAction func sendRequestAction(_ sender: Any) {
        
        HelperAlamofires().postSendRequestForAplug(userLat: self.currentUser.string(forKey: "userLatitude")! , userLong: self.currentUser.string(forKey: "userLongitude")!, spotId: "\(self.chargingPointsArrayWithDistancesSortedForDetails.2["_id"])") { (status, json) in
            if status{
                
                // crutch for google Api Direction
                self.currentUser.set(self.chargingPointsArrayWithDistancesSortedForDetails.0, forKey: "currentSpotDistance")
                self.currentUser.set("\(self.chargingPointsArrayWithDistancesSortedForDetails.2)", forKey: "currentSpotJson")
                // crutch for google Api Direction END           
                
                self.cancelButton.isHidden = false
                self.chargeButton.isHidden = true
            }
        }
    }
    
    
    @IBAction func CanceledPrivateHostRequest(_ sender: Any) {
        HelperAlamofires().putCanceledPrivateHostRequestBeforeConfirmation(userId: currentUser.string(forKey: "userid")!, historyId: self.currentUser.string(forKey: "historyIdWhenSendRequestForAplug")!) { (status, rejson) in
            
            if status{
                ShowAlertForAppDelegateNSObject().showAlert(text: "You had succesfully cancel your request", controller: UIApplication.topViewController()!)
                
                self.cancelButton.isHidden = true
                self.chargeButton.isHidden = false
            }
        }
    }
    
    
    @IBAction func removeSpotAction(_ sender: Any) {
        HelperAlamofires().deleteRemovePrivateSpot { (status, json, response) in
        }
    }
    
    
    @IBAction func goToChargingPointsTableViewController(_ sender: Any) {
        self.navigationController?.performSegue(withIdentifier: "toChargingPointsTable", sender: self.navigationController)
    }
    
    
}
