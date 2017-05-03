//
//  ShowAlertForAppDelegateNSObject.swift
//  TestApplication
//
//  Created by AzinecLLC on 3/24/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit

class ShowAlertForAppDelegateNSObject: NSObject {
    //    let topController = UIApplication.topViewController() 
    
    func showAlertInBatteryState(text : String, controller: UIViewController){
        let alert = UIAlertController(title: "", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        
        controller.present(alert, animated: true, completion: nil)
    }
   
    
    func showAlert(text : String, controller: UIViewController){
        let alert = UIAlertController(title: "", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    
}
