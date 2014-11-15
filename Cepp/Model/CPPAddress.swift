//
//  CPPAddress.swift
//  Cepp
//
//  Created by Filipe Alvarenga on 14/11/14.
//  Copyright (c) 2014 Filipe Alvarenga. All rights reserved.
//

import UIKit

class CPPAddress {
    
    var streetAddress: String!
    var zipcode: String!
    var neighborhood: String!
    var city: String!
    var state: String!
    
    init(dictionary: Dictionary<String, String>) {
        self.streetAddress = dictionary["logradouro"]
        self.zipcode = dictionary["cep"]
        self.neighborhood = dictionary["bairro"]
        self.city = dictionary["localidade"]
        self.state = dictionary["uf"]
    }
}
