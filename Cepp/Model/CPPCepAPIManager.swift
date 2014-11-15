//
//  CPPCepAPIManager.swift
//  Cepp
//
//  Created by Filipe Alvarenga on 14/11/14.
//  Copyright (c) 2014 Filipe Alvarenga. All rights reserved.
//

import UIKit

class CPPCepAPIManager: NSObject {
    
    let apiManager = AFHTTPRequestOperationManager()
    let baseURL = "http://cep.correiocontrol.com.br/%@.json"
    
    func getAddressWithCep(cep: String, inout address: CPPAddress) -> Void {
        
        var requestURL = String(format: self.baseURL, cep)
        
        self.apiManager.GET(requestURL, parameters: nil,success:
            {(operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                if let JSONAdress = responseObject as? Dictionary<String, String> {
                    NSLog("%@", JSONAdress)
                    address = CPPAddress(dictionary: JSONAdress)
                }
            })
            {(operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                //TODO: Treat error!
//                NSLog("Falhou! %@", error.description)
            }
    }
}
