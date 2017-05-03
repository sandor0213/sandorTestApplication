//
//  HelperDetailsChargingPointViewController.swift
//  TestApplication
//
//  Created by AzinecLLC on 4/21/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON

class HelperDetailsChargingPointViewController: NSObject {
    
    
    func getChargerTypesFromArrayToString(chargerTypesArray : [JSON]) -> String {
        var chargerTypesArrayString = [String]()
        var chargerTypes = ""
        
        for item in chargerTypesArray{
            chargerTypesArrayString.append(item["name"].stringValue)
        }
        for counter in 0..<chargerTypesArrayString.count {
            if counter == 0{
                chargerTypes = chargerTypesArrayString[counter]
            } else {
                chargerTypes += (", " + chargerTypesArrayString[counter])
            }
        }
        return chargerTypes
    } 
  
    
    
}



