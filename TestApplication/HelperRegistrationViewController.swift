//
//  HelperRegistrationViewController.swift
//  TestApplication
//
//  Created by AzinecLLC on 4/4/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit

class HelperRegistrationViewController: NSObject {
    
        func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    
    func validateName(firstAndLastName : String) -> Bool {
        guard firstAndLastName.characters.count > 4 else { return false}
        
        let capitalLetterRegEx  = "^[A-Za-z]+$"
        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        guard texttest.evaluate(with: firstAndLastName) else { return false }
        return true
    }
    
    func registrationControlTheUserDatas (firstAndLastName : String, userName : String, email : String, password : String) -> String{
        var warning = ""
        let usernameCharactersCount = 5
        let warningFirstAndLastName = "Your First Name and Last Name should contain at least 5 letters. "
        let warningUserName = "Your username should contain at least 6 symbols. "
        let warningEmail = "The e-mail is not valid. "
        let warningPassword = "Your password should contain at least 8 both numeric alphabetic symbols. "
        
        if firstAndLastName == "" || userName == "" || email == "" || password == ""{
            warning = "Please fill all the fields"
        }
            
        else if !validateName(firstAndLastName : firstAndLastName) && userName.characters.count <= usernameCharactersCount && !isValidEmail(testStr: email) && !HelperLoginViewController().validate(password: password) {
            warning = warningFirstAndLastName + warningEmail + warningUserName +  warningPassword
        }
            
            
        else if !validateName(firstAndLastName : firstAndLastName) && userName.characters.count <= usernameCharactersCount && !isValidEmail(testStr: email) {
            warning = warningFirstAndLastName + warningEmail + warningUserName
        }
        else if !validateName(firstAndLastName : firstAndLastName) && userName.characters.count <= usernameCharactersCount && !HelperLoginViewController().validate(password: password) {
            warning = warningFirstAndLastName + warningUserName + warningPassword
        }
        else if !validateName(firstAndLastName : firstAndLastName) && !isValidEmail(testStr: email) && !HelperLoginViewController().validate(password: password) {
            warning = warningFirstAndLastName + warningEmail + warningPassword
        }
        else if userName.characters.count <= usernameCharactersCount && !isValidEmail(testStr: email) && !HelperLoginViewController().validate(password: password) {
            warning = warningEmail + warningUserName + warningPassword
        }
            
            
        else if !validateName(firstAndLastName : firstAndLastName) && userName.characters.count <= usernameCharactersCount {
            warning = warningFirstAndLastName + warningUserName
        }
        else if !validateName(firstAndLastName : firstAndLastName) && !HelperLoginViewController().validate(password: password) {
            warning = warningFirstAndLastName + warningPassword
        }
        else if !validateName(firstAndLastName : firstAndLastName) && !isValidEmail(testStr: email) {
            warning = warningFirstAndLastName + warningEmail
        }
        else if userName.characters.count <= usernameCharactersCount && !HelperLoginViewController().validate(password: password) {
            warning = warningUserName + warningPassword
        }
        else if userName.characters.count <= usernameCharactersCount && !isValidEmail(testStr: email) {
            warning = warningEmail + warningUserName
        }
        else if !isValidEmail(testStr: email) && !HelperLoginViewController().validate(password: password) {
            warning = warningEmail + warningPassword
        }
            
            
        else if !validateName(firstAndLastName : firstAndLastName) {
            warning = warningFirstAndLastName
        }
        else if userName.characters.count <= usernameCharactersCount {
            warning = warningUserName
        }
        else if !HelperLoginViewController().validate(password: password) {
            warning = warningPassword
        }
        else if !isValidEmail(testStr: email) {
            warning = warningEmail
        } else {
            warning = "The data correspond"          
        }
        return warning
    }
    
    //***show warning label
    func warning(warningLabel : UILabel, warningText : String){
        warningLabel.text = warningText
        warningLabel.alpha = 100
        warningLabel.isHidden = false
        UIView.animate(withDuration: 5) {
            warningLabel.alpha = 0 
        }   
    }
    
    
}
