//
//  HelperLoginViewController.swift
//  TestApplication
//
//  Created by AzinecLLC on 4/3/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit
import JWT

class HelperLoginViewController: NSObject {
    
    let currentUser = UserDefaults.standard

    
    func validate(password: String) -> Bool {
        guard password.characters.count >= 8 else { return false}
        
        let capitalLetterRegEx  = ".*[A-Za-z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        guard texttest.evaluate(with: password) else { return false }
        
        let numberRegEx  = ".*[0-9]+.*"
        let texttest1 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        guard texttest1.evaluate(with: password) else { return false }
        
        return true
    } 
    
    
    
    func loginControlTheUserDatas (userName : String, password : String) -> String{
        var warning = ""
        let usernameCharactersCount = 5
        let warningUserName = "Invalid Username. Please use your Username. "
        let warningPassword = "Password should contain at least 8 both numeric alphabetic symbols."
        if userName == "" || password == "" {
            warning = "Please fill all the fields"
        }
        else if userName.characters.count <= usernameCharactersCount && !validate(password: password){
            warning = warningUserName + warningPassword
        }
        else if userName.characters.count <= usernameCharactersCount {
            warning = warningUserName
        }
        else if !validate(password: password) {
            warning = warningPassword
        } else {
            warning = "The data correspond"           
        }
        
        return warning
    }
    
    
    func createTokenForManual(userName:String, password:String, deviceSignature:String)->String{
        
        let token = JWT.encode(.hs512("secret".data(using: .utf8)!)) { (builder) in
            builder["userName"]        = userName
            builder["password"]        = password
            builder["deviceSignature"] = currentUser.value(forKey: "deviceToken")
        }
        
        currentUser.set(token, forKey: "userToken")
        return token
    }
  
    
}
