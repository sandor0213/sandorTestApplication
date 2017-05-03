//
//  ShowAlertForAppDelegateNSObject.swift
//  TestApplication
//
//  Created by AzinecLLC on 3/24/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit

class ShowAlertForAppDelegateNSObject: NSObject {
    let currentUser = UserDefaults.standard
    
    
    func showAlert(text : String, controller: UIViewController){
        let alert = UIAlertController(title: "", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    
    
    func showAlertWhenLogOut(controller: UIViewController){
        let alert = UIAlertController(title: "", message: "If you log out, then your request will be canceled or your spot will be deleted", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Log out", style: UIAlertActionStyle.default, handler: { (action) in
            
            self.currentUser.set(false, forKey: "isLogined")
            if self.currentUser.bool(forKey: "ownerOfSpot"){
                HelperAlamofires().deleteRemovePrivateSpot(completitionHandler: { (staus, json, response) in
                })  
                
            } else if self.currentUser.bool(forKey: "sendedRequest"){   
                HelperAlamofires().putCanceledPrivateHostRequestBeforeConfirmation(userId: self.currentUser.string(forKey: "userid")!, historyId: self.currentUser.string(forKey: "historyIdWhenSendRequestForAplug")!, completitionHandler: { (status, json) in
                })
            } 
            
            controller.navigationController?.performSegue(withIdentifier: "fromFirstViewToLoginViewController", sender: controller.navigationController)
        }))
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    
    
    func showAlertemptyTextAndPerformSegue(text: String, controller: UIViewController, identifier: String){
        let alert = UIAlertController(title: "", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            
            controller.navigationController?.performSegue(withIdentifier: identifier, sender: controller.navigationController)
        }))
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    
    
}

