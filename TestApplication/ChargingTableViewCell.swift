//
//  ChargingTableViewCell.swift
//  TestApplication
//
//  Created by AzinecLLC on 3/28/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChargingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chargingPointNameLabel: UILabel!
    
    @IBOutlet weak var DistanceToTheChargingPointLabel: UILabel!
    
    @IBOutlet weak var chargingPointaddressLabel: UILabel!
    
    @IBOutlet weak var sendRequestForCharge: UIButton!
    
    @IBOutlet weak var cancelRequestForChargingFromSenderButton: UIButton!
    
    @IBOutlet weak var spotOwnerImageview: UIImageView!
    
    var variableView : ChargingPointsTableViewController! = nil
    
    let currentUser = UserDefaults.standard
    
    var spotId = ""
    
    // crutch for google Api Direction
    var chargingPointsArrayWithDistancesSortedForDetails : (String, Double, JSON) = ("", 0.0, JSON(""))
    // crutch for google Api Direction END
    
    func setUp (name: String, distance : String, address : String, tableView : ChargingPointsTableViewController! = nil) {
        if tableView != nil{
            self.variableView = tableView
        }
        self.chargingPointNameLabel.text = name
        self.DistanceToTheChargingPointLabel.text = distance
        self.chargingPointaddressLabel.text = address
    }
    
    
    override func awakeFromNib() {
        NotificationCenter.default.addObserver(self, selector: #selector(cancelButtonHiddenWhenStartedCharging), name: NSNotification.Name(rawValue: "startCharge"), object: nil)
        
        super.awakeFromNib()
        
        self.spotOwnerImageview.layer.cornerRadius = self.spotOwnerImageview.frame.width / 2
        self.spotOwnerImageview.layer.masksToBounds = true
        
        if self.currentUser.bool(forKey: "ownerOfSpot"){
            self.sendRequestForCharge.isHidden = true
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    

    @IBAction func sendRequestAction(_ sender: Any) {
    
        HelperAlamofires().postSendRequestForAplug(userLat: self.currentUser.string(forKey: "userLatitude")! , userLong: self.currentUser.string(forKey: "userLongitude")!, spotId: self.spotId) { (status, json) in
 
            if self.currentUser.bool(forKey: "sendedRequest") && self.spotId == self.currentUser.string(forKey: "selectedSpotId")! {  
                
                // crutch for google Api Direction
                self.currentUser.set(self.chargingPointsArrayWithDistancesSortedForDetails.0, forKey: "currentSpotDistance")
                self.currentUser.set("\(self.chargingPointsArrayWithDistancesSortedForDetails.2)", forKey: "currentSpotJson")
                // crutch for google Api Direction END
                
                self.cancelRequestForChargingFromSenderButton.isHidden = false
                self.variableView.tableView.reloadData()
            }  
        }
    }
    
    
    @IBAction func CanceledPrivateHostRequest(_ sender: Any) { 
        HelperAlamofires().putCanceledPrivateHostRequestBeforeConfirmation(userId: currentUser.string(forKey: "userid")!, historyId: self.currentUser.string(forKey: "historyIdWhenSendRequestForAplug")!) { (status, rejson) in
           
                if status{
                    
                    ShowAlertForAppDelegateNSObject().showAlert(text: "You had succesfully cancel your request", controller: UIApplication.topViewController()!)
                
                self.cancelRequestForChargingFromSenderButton.isHidden = true                
                self.variableView.locationManager.startUpdatingLocation()
                
                self.variableView.tableView.reloadData()  
            }
        }  
    }
    
    
    func cancelButtonHiddenWhenStartedCharging(){
        self.cancelRequestForChargingFromSenderButton.isHidden = true
    }
    
    
}
