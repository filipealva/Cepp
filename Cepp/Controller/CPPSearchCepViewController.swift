//
//  CPPSearchCepViewController.swift
//  Cepp
//
//  Created by Filipe Alvarenga on 14/11/14.
//  Copyright (c) 2014 Filipe Alvarenga. All rights reserved.
//

import UIKit

class CPPSearchCepViewController: UIViewController {
    // FA NOTE: Special thanks to Mauricio T. Zaquia by his Auto Layout lesson! :D
    @IBOutlet weak var searchCepContainerView: UIView!
    @IBOutlet weak var keyboardConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var cep: UITextField!
    
    private var initialConstant: CGFloat = 0
    private var address: CPPAddress!
    var centerSearchViewConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Adding the centerY constraint programmatically because we need to manage when add or remove this constraint
        self.centerSearchViewConstraint = NSLayoutConstraint(item: self.searchCepContainerView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        
        view.addConstraint(self.centerSearchViewConstraint)
        
        //Adding the keyboard notifications on notification center
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        //Hidding the keyboard
        self.hideKeyboard()
    }
    
    // MARK: - Actions
    
    @IBAction func searchButtonWasTouched(sender: UIButton) {
        if (self.cep.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
            self.startLoading()
            //Calling the APIManager method that gets the address by the zipcode
            CPPCepAPIManager().getAddressWithCep(self.cep.text, success: { (responseObject) -> Void in
                //Verifying the responseObject and creating the CPPAdress
                if let JSONAdress = responseObject as? Dictionary<String, String> {
                    self.address = CPPAddress(dictionary: JSONAdress)
                    //Calling the APIManager method that geocode the address
                    CPPCepAPIManager().geocodeAddress(self.address, callback: { (placemark) -> Void in
                        //Configuring the address location and showing the details view
                        self.address.location = placemark.coordinate
                        self.performSegueWithIdentifier("showCepDetails", sender: self)
                        self.stopLoading()
                    })
                }
            }) { (error) -> Void in
                //Notifying the user that an error ocurred
                //TODO: Treat the error
                NSLog("%@", error.description)
                self.stopLoading()
            }
        } else {
            //Notifying the user that he must enter a zipcode before search
            var emptyAlert = UIAlertView(title: "Oops!", message: "Digite o CEP antes de buscar :)", delegate: nil, cancelButtonTitle: "Entendi")
            emptyAlert.show()
            self.stopLoading()
        }
    }
    
    //Method that puts the view in loading state
    func startLoading() -> Void {
        self.hideKeyboard()
        self.activityIndicator.alpha = 1.0
        self.activityIndicator.startAnimating()
        self.searchButton.enabled = false
    }
    
    //Method that puts the view in normal state
    func stopLoading() -> Void {
        self.hideKeyboard()
        self.activityIndicator.alpha = 0
        self.activityIndicator.stopAnimating()
        self.searchButton.enabled = true
    }
    
    //Method that hides the keyboard
    func hideKeyboard() -> Void {
        self.view.endEditing(true)
    }
    
    //Method that adjust the searchCepContainerView when the keyboard will show
    func keyboardWillShow(notification: NSNotification) {
        let dict = notification.userInfo as [NSString:NSObject]
        let keyboardSize = (dict[UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue().size
        
        view.removeConstraint(self.centerSearchViewConstraint)
        
        if initialConstant == 0 {
            initialConstant = keyboardConstraint.constant
        }
        
        keyboardConstraint.constant = keyboardSize.height + 30
        
        let animationDuration = Double(dict[UIKeyboardAnimationDurationUserInfoKey] as NSNumber) as NSTimeInterval
        UIView.animateWithDuration(animationDuration) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    //Method that adjust the searchCepContainerView when the keyboard will hide
    func keyboardWillHide(notification: NSNotification) {
        let dict = notification.userInfo as [NSString:NSObject]
        
        view.addConstraint(self.centerSearchViewConstraint)
        
        keyboardConstraint.constant = initialConstant
        
        let animationDuration = Double(dict[UIKeyboardAnimationDurationUserInfoKey] as NSNumber) as NSTimeInterval
        UIView.animateWithDuration(animationDuration) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //Configuring the address of details view
        if (segue.identifier == "showCepDetails") {
            var detailView = segue.destinationViewController as CPPCepDetailsTableViewController
            detailView.address = self.address
        }
    }

}
