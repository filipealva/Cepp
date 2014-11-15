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
        
        self.centerSearchViewConstraint = NSLayoutConstraint(item: self.searchCepContainerView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        
        view.addConstraint(self.centerSearchViewConstraint)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.hideKeyboard()
    }
    
    // MARK : - Actions
    
    @IBAction func searchButtonWasTouched(sender: UIButton) {
        if (self.cep.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
            self.startLoading()
            CPPCepAPIManager().getAddressWithCep(self.cep.text, success: { (responseObject) -> Void in
                if let JSONAdress = responseObject as? Dictionary<String, String> {
                    NSLog("Funcionou: %@", JSONAdress)
                    self.address = CPPAddress(dictionary: JSONAdress)
                    self.performSegueWithIdentifier("showCepDetails", sender: self)
                    self.stopLoading()
                }
            }) { (error) -> Void in
                NSLog("%@", error.description)
                self.stopLoading()
            }
        } else {
            var emptyAlert = UIAlertView(title: "Oops!", message: "Digite o CEP antes de buscar :)", delegate: nil, cancelButtonTitle: "Entendi")
            emptyAlert.show()
            self.stopLoading()
        }
    }
    
    func startLoading() -> Void {
        self.hideKeyboard()
        self.activityIndicator.alpha = 1.0
        self.activityIndicator.startAnimating()
        self.searchButton.enabled = false
    }
    
    func stopLoading() -> Void {
        self.hideKeyboard()
        self.activityIndicator.alpha = 0
        self.activityIndicator.stopAnimating()
        self.searchButton.enabled = true
    }
    
    func hideKeyboard() -> Void {
        self.view.endEditing(true)
    }
    
    func getAddressInfo() {
        var cep: String! = "94045020"
        CPPCepAPIManager().getAddressWithCep(cep, success: { (responseObject) -> Void in
            if let JSONAdress = responseObject as? Dictionary<String, String> {
                NSLog("Funcionou: %@", JSONAdress)
                var address = CPPAddress(dictionary: JSONAdress)
            }
        }) { (error) -> Void in
            NSLog("%@", error.description)
        }
    }
    
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
        if (segue.identifier == "showCepDetails") {
            var detailView = segue.destinationViewController as CPPCepDetailsTableViewController
            detailView.address = self.address
        }
    }

}
