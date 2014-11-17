//
//  CPPSearchCepViewController.swift
//  Cepp
//
//  Created by Filipe Alvarenga on 14/11/14.
//  Copyright (c) 2014 Filipe Alvarenga. All rights reserved.
//

import UIKit

class CPPSearchCepViewController: UIViewController, UITextFieldDelegate {
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
        
        self.cep.delegate = self
        
        //Adding the centerY constraint programmatically because we need to manage when add or remove this constraint
        self.centerSearchViewConstraint = NSLayoutConstraint(item: self.searchCepContainerView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        
        view.addConstraint(self.centerSearchViewConstraint)
        
        //Adding the keyboard notifications on notification center
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.cep.text = ""
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
            CPPCepAPIManager().getAddressWithCep(self.removeCepFormatter(self.cep.text), success: { (responseObject) -> Void in
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
                if (error.code == -1009) {
                    var noConnectionAlert = UIAlertView(title: "Oops :(", message: "Não foi possível buscar o endereço, verifique sua conexão", delegate: nil, cancelButtonTitle: "Ok")
                    noConnectionAlert.show()
                } else {
                    var invalidZipcode = UIAlertView(title: "Oops!", message: "CEP inválido", delegate: nil, cancelButtonTitle: "Ok")
                    invalidZipcode.show()
                }
                self.stopLoading()
            }
        } else {
            //Notifying the user that he must enter a zipcode before search
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
    
    func removeCepFormatter(cepFormatted: String) -> String {
        return cepFormatted.stringByReplacingOccurrencesOfString("-", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
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

    //MARK: UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //Getting the textfield text
        var text: NSString = textField.text as NSString
        text = text.stringByReplacingCharactersInRange(range, withString: string)
        
        //Adding the textfield text on a mutable string
        var mutableString: NSMutableString = text.mutableCopy() as NSMutableString
        
        //Verifying if the user not tapped the delete key
        if(!(range.length == 1 && string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0)) {
            //Limiting the text length
            if (text.length == 10) {
                return false
            }
            
            //Adding the formatter character at the correct position
            if (mutableString.length == 6) {
                if (mutableString.characterAtIndex(5).description != "-") {
                    mutableString.insertString("-", atIndex: 5)
                }
            }
        }
        
        //Putting the string with the formatter character on the textfield
        textField.text = mutableString
        
        return false
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
