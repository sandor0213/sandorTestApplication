//
//  LoginViewController.swift
//  TestApplication
//
//  Created by AzinecLLC on 4/3/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit
import ReachabilitySwift
import UserNotifications

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var loginUserNameTextfield: UITextField!
    
    @IBOutlet weak var loginPasswordTextfield: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var forFrameView: UIView!
    
    var frame : CGFloat = 0
    
    let reachability = Reachability()!
    
    let currentUser = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.currentUser.bool(forKey: "isLogined") {
            DispatchQueue.main.async {
                self.navigationController?.performSegue(withIdentifier: "toChargingPointsTable", sender: self.navigationController)
            }
        }
        
        
        self.navigationController?.isNavigationBarHidden = true
        
        self.warningLabel.isHidden = true
        self.loginUserNameTextfield.delegate = self
        self.loginPasswordTextfield.delegate = self
        
        frame = self.forFrameView.frame.origin.y
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "forFrameViewTapped")
        self.forFrameView.addGestureRecognizer(tapGesture)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func forFrameViewTapped() {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 1) { 
            self.forFrameView.frame.origin.y -= textField.frame.origin.y + textField.frame.height - 8
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 1) { 
            self.forFrameView.frame.origin.y = self.frame 
        } 
    }
    
    @IBAction func loginUserAction(_ sender: Any) {
        self.forFrameViewTapped()
        
        if reachability.isReachable{
            let resultOfCheckingLoginUserDatas : String = HelperLoginViewController().loginControlTheUserDatas(userName: loginUserNameTextfield.text!, password: loginPasswordTextfield.text!)  
            
            if resultOfCheckingLoginUserDatas == "The data correspond" {
                let deviceToken : String = currentUser.value(forKey: "deviceToken") as! String
                let token = HelperLoginViewController().createTokenForManual(userName: loginUserNameTextfield.text!, password: loginPasswordTextfield.text!, deviceSignature: deviceToken)
                
                let parameters : [String : String] = ["token" : token]
                
                HelperAlamofires().login(loginparams: parameters, completitionHandler: { (status, loginJson, responseString) in
                    if status {
                        self.navigationController?.performSegue(withIdentifier: "toChargingPointsTable", sender: self.navigationController)  
                    } else {
                        HelperRegistrationViewController().warning(warningLabel: self.warningLabel, warningText: responseString)
                    }
                })
            } else {
                HelperRegistrationViewController().warning(warningLabel: self.warningLabel, warningText: resultOfCheckingLoginUserDatas)
            }
        } else {
            HelperRegistrationViewController().warning(warningLabel: self.warningLabel, warningText: "No Internet Connection")
        }   
    }  
    
    
    
}
