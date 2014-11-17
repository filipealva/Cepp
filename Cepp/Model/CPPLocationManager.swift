//
//  CPPLocationManager.swift
//  Cepp
//
//  Created by Filipe Alvarenga on 16/11/14.
//  Copyright (c) 2014 Filipe Alvarenga. All rights reserved.
//

import UIKit

class CPPLocationManager {
    
    class var sharedInstance : CPPLocationManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : CPPLocationManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = CPPLocationManager()
        }
        return Static.instance!
    }
    
    let locationManager = CLLocationManager()
}
