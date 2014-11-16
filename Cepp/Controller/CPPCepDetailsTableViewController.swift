//
//  CPPCepDetailsTableViewController.swift
//  Cepp
//
//  Created by Filipe Alvarenga on 15/11/14.
//  Copyright (c) 2014 Filipe Alvarenga. All rights reserved.
//

import UIKit
import MapKit

class CPPCepDetailsTableViewController: UITableViewController, APParallaxViewDelegate {
    
    var address: CPPAddress!
    var addressLocation: CLLocationCoordinate2D!
    var parallaxHeader: UIView!
    var mapHeader: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        CPPCepAPIManager().geocodeAddress(self.address, success: { (placemark) -> Void in
            self.addressLocation = placemark.coordinate
            self.putAdressOnMap()
        }) { (error) -> Void in
            
        }
        
        parallaxHeader = NSBundle.mainBundle().loadNibNamed("CPPCepDetailsHeader", owner: nil, options: nil)[0] as UIView
        mapHeader = parallaxHeader.viewWithTag(100) as MKMapView
        
        self.tableView.addParallaxWithView(parallaxHeader, andHeight: 160)
        self.tableView.parallaxView.delegate = self
        
        var constW = NSLayoutConstraint(item: self.mapHeader, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.tableView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        self.view.addConstraint(constW)
    }
    
    func putAdressOnMap() -> Void {
        let annotation = MKPointAnnotation()
        annotation.setCoordinate(self.addressLocation)
        annotation.title = self.address.streetAddress
        mapHeader.addAnnotation(annotation)
        
        let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 200, 200)
        let adjusted = mapHeader.regionThatFits(region)
        mapHeader.setRegion(adjusted, animated: true)
    }
}
