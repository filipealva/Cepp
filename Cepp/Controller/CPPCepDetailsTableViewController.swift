//
//  CPPCepDetailsTableViewController.swift
//  Cepp
//
//  Created by Filipe Alvarenga on 15/11/14.
//  Copyright (c) 2014 Filipe Alvarenga. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CPPCepDetailsTableViewController: UITableViewController, APParallaxViewDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
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
        
        self.parallaxHeader = NSBundle.mainBundle().loadNibNamed("CPPCepDetailsHeader", owner: nil, options: nil)[0] as UIView
        self.mapHeader = self.parallaxHeader.viewWithTag(100) as MKMapView
        
        self.tableView.addParallaxWithView(self.parallaxHeader, andHeight: 160)
        self.tableView.parallaxView.delegate = self
        
        self.mapHeader.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var constW = NSLayoutConstraint(item: self.mapHeader, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.tableView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        self.view.addConstraint(constW)
    }
    
    //MARK: - Actions
    
    func putAdressOnMap() -> Void {
        let annotation = MKPointAnnotation()
        annotation.setCoordinate(self.addressLocation)
        annotation.title = self.address.streetAddress
        self.mapHeader.addAnnotation(annotation)
        
        let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 200, 200)
        let adjusted = self.mapHeader.regionThatFits(region)
        self.mapHeader.setRegion(adjusted, animated: true)
    }
    
    @IBAction func traceRouteButtonTouched(sender: UIBarButtonItem) {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestWhenInUseAuthorization()

        if (CLLocationManager.locationServicesEnabled()) {
            self.locationManager.startUpdatingLocation()
        } else {
            var locationServicesDisabledAlert = UIAlertView(title: "Vish!", message: "Você precisa autorizar os serviços de localização para o Cepp em suas configurações :)", delegate: nil, cancelButtonTitle: "Entendi")
            
            locationServicesDisabledAlert.show()
        }
    }
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.address.location = manager.location.coordinate
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        var errorWhenGetLocation = UIAlertView(title: "Oops!", message: "Ocorreu algum erro enquanto tentavamos pegar a sua localização :(", delegate: nil, cancelButtonTitle: "Beleza, vou tentar novamente")
        
        errorWhenGetLocation.show()
    }
    
}
