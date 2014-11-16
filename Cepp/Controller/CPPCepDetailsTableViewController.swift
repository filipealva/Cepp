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

class CPPCepDetailsTableViewController: UITableViewController, UIActionSheetDelegate, APParallaxViewDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    var address: CPPAddress!
    var userLocation: CLLocationCoordinate2D!
    var parallaxHeader: UIView!
    var mapHeader: MKMapView!
    var isWazeInstalled: Bool!
    var isGoogleMapsInstalled: Bool!
    var routeOptions = [String]()
    
    let WAZE_TITLE = "Waze"
    let GOOGLEMAPS_TITLE = "Google Maps"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        CPPCepAPIManager().geocodeAddress(self.address, success: { (placemark) -> Void in
            self.address.location = placemark.coordinate
            self.putAdressOnMap()
        }) { (error) -> Void in
            
        }
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()) {
            self.locationManager.startUpdatingLocation()
        } else {
            var locationServicesDisabledAlert = UIAlertView(title: "Vish!", message: "Você precisa autorizar os serviços de localização para o Cepp em suas configurações :)", delegate: nil, cancelButtonTitle: "Entendi")
            
            locationServicesDisabledAlert.show()
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
        annotation.setCoordinate(self.userLocation)
        annotation.title = self.address.streetAddress
        
        self.mapHeader.addAnnotation(annotation)
        
        let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 200, 200)
        let adjusted = self.mapHeader.regionThatFits(region)
        
        self.mapHeader.setRegion(adjusted, animated: true)
    }
    
    func traceRoute(app: CMMapApp) {
        var mapPoint = CMMapPoint(name: self.address.streetAddress, coordinate: self.address.location)
        CMMapLauncher.launchMapApp(app, forDirectionsTo: mapPoint)
    }
    
    func verifyRouteOptions() -> Void {
        self.isWazeInstalled = CMMapLauncher.isMapAppInstalled(CMMapApp.Waze)
        self.isGoogleMapsInstalled = CMMapLauncher.isMapAppInstalled(CMMapApp.GoogleMaps)
        
        if (!self.isGoogleMapsInstalled && !self.isWazeInstalled) {
            self.traceRoute(CMMapApp.AppleMaps)
        } else {
            self.routeOptions.append("Maps")
            
            if (self.isGoogleMapsInstalled == true) {
                self.routeOptions.append(self.GOOGLEMAPS_TITLE)
            }
            
            if (self.isWazeInstalled == true) {
                self.routeOptions.append(self.WAZE_TITLE)
            }
            
            var mapAppAsk = UIActionSheet()
            mapAppAsk.title = "Com qual app você prefere?"
            mapAppAsk.delegate = self
            
            for app in self.routeOptions {
                mapAppAsk.addButtonWithTitle(app)
            }
            
            mapAppAsk.cancelButtonIndex = mapAppAsk.addButtonWithTitle("Cancelar")
            mapAppAsk.showInView(self.view)
        }
        
    }
    
    @IBAction func traceRouteButtonTouched(sender: UIBarButtonItem) {
        self.verifyRouteOptions()
    }
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.userLocation = manager.location.coordinate
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        var errorWhenGetLocation = UIAlertView(title: "Oops!", message: "Ocorreu algum erro enquanto tentavamos pegar a sua localização :(", delegate: nil, cancelButtonTitle: "Beleza, vou tentar novamente")
        
        errorWhenGetLocation.show()
    }
    
    //MARK: UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex != self.routeOptions.count) {
            var buttonTitle = self.routeOptions[buttonIndex]
            
            if (buttonIndex == 0) {
                self.traceRoute(CMMapApp.AppleMaps)
            } else if (buttonTitle == self.GOOGLEMAPS_TITLE) {
                self.traceRoute(CMMapApp.GoogleMaps)
            } else {
                self.traceRoute(CMMapApp.Waze)
            }
        }
    }
    
}
