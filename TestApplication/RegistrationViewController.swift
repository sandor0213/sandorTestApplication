//
//  RegistrationViewController.swift
//  TestApplication
//
//  Created by AzinecLLC on 4/4/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit
import ReachabilitySwift

class RegistrationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var registrationFirstNameAndLastNameTextfield: UITextField!
    
    @IBOutlet weak var registrationEmailTextfield: UITextField!
    
    @IBOutlet weak var registrationUserNameTextfield: UITextField!
    
    @IBOutlet weak var registrationPasswordTextfield: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var forFrameView: UIView!
    
    @IBOutlet weak var logInButton: UIButton!
    
    var frame : CGFloat = 0
    
    let reachability = Reachability()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        self.warningLabel.isHidden = true
        self.registrationFirstNameAndLastNameTextfield.delegate = self
        self.registrationEmailTextfield.delegate = self
        self.registrationUserNameTextfield.delegate = self
        self.registrationPasswordTextfield.delegate = self 
        
        frame = self.forFrameView.frame.origin.y
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "forFrameViewTapped")
        self.forFrameView.addGestureRecognizer(tapGesture)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    @IBAction func signUpAction(_ sender: Any) {
        self.forFrameViewTapped()
        if reachability.isReachable{
            let resultOfCheckingRegistrationUserDatas : String = HelperRegistrationViewController().registrationControlTheUserDatas(firstAndLastName: self.registrationFirstNameAndLastNameTextfield.text!, userName: self.registrationUserNameTextfield.text!, email: self.registrationEmailTextfield.text!, password: self.registrationPasswordTextfield.text!)
            
            if resultOfCheckingRegistrationUserDatas == "The data correspond" {
                let parameters : [String:String] = [
                    "firstName":self.registrationFirstNameAndLastNameTextfield.text!,
                    "email":self.registrationEmailTextfield.text!,
                    "userName":self.registrationUserNameTextfield.text!,
                    "password":self.registrationPasswordTextfield.text!,
                    "gender":"Unknown",
                    "birthday":"123213",
                    "provider":"plugspot"
                ]
                HelperAlamofires().registration(regparams: parameters, completitionHandler: { (status, registrationJson, responseString) in
                    if status {
                        self.navigationController?.performSegue(withIdentifier: "fromFirstViewToLoginViewController", sender: self.navigationController)  
                    } else {
                        HelperRegistrationViewController().warning(warningLabel: self.warningLabel, warningText: responseString)       
                    }
                })
            } else {
                HelperRegistrationViewController().warning(warningLabel: self.warningLabel, warningText: resultOfCheckingRegistrationUserDatas)
            }
        } else {
            HelperRegistrationViewController().warning(warningLabel: self.warningLabel, warningText: "No Internet Connection")
        }   
    }  
    
    
    @IBAction func goToLoginAction(_ sender: Any) {
        self.navigationController?.performSegue(withIdentifier: "fromFirstViewToLoginViewController", sender: self.navigationController)
    }
    
    
}



