//
//  MenuViewController.swift
//  TestApplication
//
//  Created by AzinecLLC on 4/26/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON

class MenuViewController: UIViewController {
    
    @IBOutlet weak var listButton: UIBarButtonItem!
    
    @IBOutlet weak var logOutButton: UIButton!
    
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    let currentUser = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isToolbarHidden = true        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logOutAction(_ sender: Any) {
        
        if self.currentUser.bool(forKey: "ownerOfSpot") || self.currentUser.bool(forKey: "sendedRequest") {
            ShowAlertForAppDelegateNSObject().showAlertWhenLogOut(controller: self)   
        
        } else {
            self.currentUser.set(false, forKey: "isLogined")
            self.navigationController?.performSegue(withIdentifier: "fromFirstViewToLoginViewController", sender: self.navigationController) 
        }
    }
    
    
    @IBAction func deleteAccountAction(_ sender: Any) {
    }
    
    
    
    
    
    @IBAction func goToChargingPointsTableViewController(_ sender: Any) {
        self.navigationController?.performSegue(withIdentifier: "toChargingPointsTable", sender: self.navigationController)
    }
    
    
  
}
