//
//  CPPCepDetailsTableViewController.swift
//  Cepp
//
//  Created by Filipe Alvarenga on 15/11/14.
//  Copyright (c) 2014 Filipe Alvarenga. All rights reserved.
//

import UIKit

class CPPCepDetailsTableViewController: UITableViewController, APParallaxViewDelegate {
    
    var address: CPPAddress!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var mapHeader: UIView = NSBundle.mainBundle()
                                        .loadNibNamed("CPPCepDetailsHeader", owner: nil, options: nil)[0] as UIView
        
        self.tableView.addParallaxWithView(mapHeader, andHeight: 160)
        self.tableView.parallaxView.delegate = self
    }

}
