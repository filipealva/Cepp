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
    
    @IBOutlet weak var userDistanceToAddress: UILabel!
    @IBOutlet weak var streetAddress: UILabel!
    @IBOutlet weak var zipcode: UILabel!
    @IBOutlet weak var cityAndState: UILabel!
    
    let locationManager = CLLocationManager()
    
    var address: CPPAddress!
    var userLocation: CLLocation!
    var parallaxHeader: UIView!
    var mapHeader: MKMapView!
    var isWazeInstalled: Bool!
    var isGoogleMapsInstalled: Bool!
    var routeOptions = [String]()
    
    let WAZE_TITLE = "Waze"
    let GOOGLEMAPS_TITLE = "Google Maps"

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.putAdressOnMap()
        
        self.streetAddress.text = self.address.streetAddress
        self.zipcode.text = self.address.zipcode
        self.cityAndState.text = String(format: "%@ - %@", self.address.city, self.address.state)
    }
    
    //MARK: - Actions
    
    func putAdressOnMap() -> Void {
        let annotation = MKPointAnnotation()
        annotation.setCoordinate(self.address.location)
        annotation.title = self.address.streetAddress
        
        self.mapHeader.addAnnotation(annotation)
        self.mapHeader.selectAnnotation(annotation, animated: true)
        
        let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 200, 200)
        let adjusted = self.mapHeader.regionThatFits(region)
        
        self.mapHeader.setRegion(adjusted, animated: true)
    }
    
    func traceRoute(app: CMMapApp) {
        
        if (self.address.location != nil) {
            var mapPoint = CMMapPoint(name: self.address.streetAddress, coordinate: self.address.location)
            CMMapLauncher.launchMapApp(app, forDirectionsTo: mapPoint)
        } else {
            var geocodeFailureAlert = UIAlertView(title: "Oops!", message: "Não conseguimos encontrar este endereço no mapa :(", delegate: nil, cancelButtonTitle: "Entendo...")
            
            geocodeFailureAlert.show()
        }
        
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
        self.userLocation = manager.location
        self.locationManager.stopUpdatingLocation()
        
        if let addressCoordinate = self.address.location {
            var distanceToAddress: double_t = self.userLocation.distanceFromLocation(CLLocation(latitude: self.address.location.latitude, longitude: self.address.location.longitude)) as double_t
            self.userDistanceToAddress.text = String (format: "Você está a %.2fkm deste endereço", distanceToAddress / 1000)
        } else {
            self.userDistanceToAddress.text = "Ocorreu um erro durante o calculo de distância :("
        }
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
