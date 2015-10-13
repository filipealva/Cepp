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

class CPPCepDetailsTableViewController: UITableViewController, UIActionSheetDelegate, CLLocationManagerDelegate {
    
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
        
        //Configuring the location manager
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        let osVersion = UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch)
        
        if (osVersion == .OrderedSame || osVersion == .OrderedDescending) {
            if #available(iOS 8.0, *) {
                self.locationManager.requestWhenInUseAuthorization()
            } else {
                // Fallback on earlier versions
            }
        }
        
        //Verifying if the user allowed the location services
        if (CLLocationManager.locationServicesEnabled()) {
            //Starting the location updates
            self.locationManager.startUpdatingLocation()
        } else {
            //Notifying the user that he must allows us to get your location
            let locationServicesDisabledAlert = UIAlertView(title: "Vish!", message: "Você precisa autorizar os serviços de localização para o Cepp em suas configurações :)", delegate: nil, cancelButtonTitle: "Entendi")
            
            locationServicesDisabledAlert.show()
        }
        
        switch UIDevice.currentDevice().userInterfaceIdiom {
            case .Pad:
                //Configuring the UITableView parallax header for iPad
                self.parallaxHeader = NSBundle.mainBundle().loadNibNamed("CPPiPadCepDetailsHeader", owner: nil, options: nil)[0] as! UIView
                self.mapHeader = self.parallaxHeader.viewWithTag(100) as! MKMapView
                
                self.tableView.addParallaxWithView(self.parallaxHeader, andHeight: 450)
            default:
                //Configuring the UITableView parallax header for iPhone
                self.parallaxHeader = NSBundle.mainBundle().loadNibNamed("CPPCepDetailsHeader", owner: nil, options: nil)[0] as! UIView
                self.mapHeader = self.parallaxHeader.viewWithTag(100) as! MKMapView
                
                self.tableView.addParallaxWithView(self.parallaxHeader, andHeight: 160)
        }

        //Configuring mapHeader width
        self.mapHeader.translatesAutoresizingMaskIntoConstraints = false
        let constW = NSLayoutConstraint(item: self.mapHeader, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.tableView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        self.view.addConstraint(constW)
        
        //Putting the address on the map
        self.putAdressOnMap()
        
        //Setting the address data on view's fields
        if (self.address.streetAddress == nil) {
            self.streetAddress.text = "Logradouro indisponível"
        } else {
            self.streetAddress.text = self.address.streetAddress
        }
        self.zipcode.text = self.formatCep(self.address.zipcode)
        self.cityAndState.text = String(format: "%@ - %@", self.address.city, self.address.state)
    }
    
    override func viewDidAppear(animated: Bool) {
        //Tracking screen with Google Analytics
        MXGoogleAnalytics.ga_trackScreen("CEP Details")
    }
    
    //MARK: - Actions
    
    func putAdressOnMap() -> Void {
        //Creating the annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = self.address.location
        
        if (self.address.streetAddress == nil) {
            annotation.title = self.address.city + " - " + self.address.state
        } else {
            annotation.title = self.address.streetAddress
        }
        
        //Adding the annotation on the map
        self.mapHeader.addAnnotation(annotation)
        self.mapHeader.selectAnnotation(annotation, animated: true)
        
        //Adjusting the map region
        let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 200, 200)
        let adjusted = self.mapHeader.regionThatFits(region)
        self.mapHeader.setRegion(adjusted, animated: true)
    }
    
    func formatCep(cep: NSString) -> String {
        let formattedCep: NSMutableString =  cep.mutableCopy() as! NSMutableString
        formattedCep.insertString("-", atIndex: 5)
        
        return formattedCep as String
    }
    
    func traceRoute(app: CMMapApp) {
        //Veryfing if the address location was successful geocoded
        if (self.address.location != nil) {
            //Launching the map app to trace a route
            let mapPoint = CMMapPoint(name: self.address.streetAddress, coordinate: self.address.location)
            CMMapLauncher.launchMapApp(app, forDirectionsTo: mapPoint)
        } else {
            //Notifying the user that the address geocode was failed
            let geocodeFailureAlert = UIAlertView(title: "Oops!", message: "Não conseguimos encontrar este endereço no mapa :(", delegate: nil, cancelButtonTitle: "Entendo...")
            
            geocodeFailureAlert.show()
        }
        
    }
    
    func verifyRouteOptions() -> Void {
        //Verifying which map apps are installed on user's device
        self.isWazeInstalled = CMMapLauncher.isMapAppInstalled(CMMapApp.Waze)
        self.isGoogleMapsInstalled = CMMapLauncher.isMapAppInstalled(CMMapApp.GoogleMaps)
        
        //Verifying if only Apple Maps app is installed
        if (!self.isGoogleMapsInstalled && !self.isWazeInstalled) {
            //Launching the Apple Maps app
            self.traceRoute(CMMapApp.AppleMaps)
        } else {
            if (self.routeOptions.count == 0) {
                //Adding the Apple Maps app on the routeOptions list
                self.routeOptions.append("Maps")
                
                //Verifying if the Google Maps app is installed
                if (self.isGoogleMapsInstalled == true) {
                    //Adding the Google Maps app on the routeOptions list
                    self.routeOptions.append(self.GOOGLEMAPS_TITLE)
                }
                
                //Verifying if the Waze App is installed
                if (self.isWazeInstalled == true) {
                    //Adding the Waze App on the routeOptions list
                    self.routeOptions.append(self.WAZE_TITLE)
                }
            }
            
            //Configuring the mapAppAsk UIActionSheet
            let mapAppAsk = UIActionSheet()
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
        //Tracking the route event
        MXGoogleAnalytics.ga_trackEventWith("CEP Details", action: "Route traced", label: self.address.zipcode)
        //Calling the method to verify the route options avaiable
        self.verifyRouteOptions()
    }
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Getting the user location and stoping the updates
        self.userLocation = manager.location
        self.locationManager.stopUpdatingLocation()
        
        //Showing to the user the distance of address
        if let _ = self.address.location {
            let distanceToAddress: double_t = self.userLocation.distanceFromLocation(CLLocation(latitude: self.address.location.latitude, longitude: self.address.location.longitude)) as double_t
            self.userDistanceToAddress.text = String (format: "Você está a %.2fkm deste endereço", distanceToAddress / 1000)
        } else {
            //If the address geocoding was failed we notify the user
            self.userDistanceToAddress.text = "Ocorreu um erro durante o calculo de distância :("
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        //Notifying the user that we can't get your location
        let errorWhenGetLocation = UIAlertView(title: "Oops!", message: "Ocorreu algum erro enquanto tentavamos pegar a sua localização :(", delegate: nil, cancelButtonTitle: "Beleza, vou tentar novamente")
        
        errorWhenGetLocation.show()
    }
    
    //MARK: UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        //Verifying which app the user choosed to trace the route
        if (buttonIndex != self.routeOptions.count) {
            let buttonTitle = self.routeOptions[buttonIndex]
            
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
