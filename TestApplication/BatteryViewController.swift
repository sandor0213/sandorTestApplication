//
//  BatteryViewController.swift
//  TestApplication
//
//  Created by AzinecLLC on 3/23/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit

class BatteryViewController: UIViewController {

  
    @IBOutlet weak var batteryLevelLabel: UILabel!
    
    @IBOutlet weak var batteryStateLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         UIDevice.current.isBatteryMonitoringEnabled = true
     
    }    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Finish observation
//        UIDevice.current.isBatteryMonitoringEnabled = false
//        
//        NotificationCenter.default.removeObserver(self,
//                                                  name: NSNotification.Name.UIDeviceBatteryStateDidChange,
//                                                  object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Internal method
    

    
   
        
//        if status == .unplugged{
//            showAlertInBatteryState(text: "Unplugged")
//            
//        }
        
        
        //        self.batteryStateLabel!.text = batteryStateString
    
    
    



}


