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
    
    func getAddressWithCep(cep: String) -> Void {
        
        var requestURL = String(format: self.baseURL, cep)
        
        self.apiManager.GET(requestURL, parameters: nil,success:
            {(operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                var adress: CPPAddress!
                if let JSONAdress = responseObject as? Dictionary<String, String> {
                    adress.initWithDictionary(JSONAdress)
                }
            })
            {(operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                //TODO: Treat error!
//                NSLog("Falhou! %@", error.description)
            }
    }
}
