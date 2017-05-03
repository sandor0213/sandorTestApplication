//
//  ProfileViewController.swift
//  TestApplication
//
//  Created by AzinecLLC on 4/25/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var userProfileimage: UIImageView!
    
    @IBOutlet weak var firstAndLastNameLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var listButton: UIBarButtonItem!
    
    let currentUser = UserDefaults.standard

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isToolbarHidden = true
        
        self.userProfileimage.layer.cornerRadius = self.userProfileimage.frame.width / 2
        self.userProfileimage.layer.masksToBounds = true
        self.userProfileimage.layer.borderWidth = 3
        self.userProfileimage.layer.borderColor = UIColor.green.cgColor
        
        let jsonFromLogin : JSON = HelperAlamofires().stringToJSON(self.currentUser.string(forKey: "loginJson")!)

        // set up profile datas
        self.firstAndLastNameLabel.text = jsonFromLogin["data"]["firstName"].stringValue
        self.usernameLabel.text = jsonFromLogin["data"]["userName"].stringValue
        self.emailLabel.text = jsonFromLogin["data"]["email"].stringValue
           // set up profile datas End 
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func goToChargingPointsTableViewController(_ sender: Any) {
        self.navigationController?.performSegue(withIdentifier: "toChargingPointsTable", sender: self.navigationController)
    }
    
  
   
}
