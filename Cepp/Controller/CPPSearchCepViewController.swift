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
    var centerSearchViewConstraint: NSLayoutConstraint!
    
    private var initialConstant: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var cep: String! = "94045060"
        
        NSLog("%@", CPPCepAPIManager().baseURL)
        
//        CPPCepAPIManager().getAddressWithCep(cep)
        
        self.centerSearchViewConstraint = NSLayoutConstraint(item: self.searchCepContainerView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        
        view.addConstraint(self.centerSearchViewConstraint)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    // MARK : - Actions
    
    func getAddressInfo() {
//        var cep: String! = "94045060"
//        if let var address? = CPPCepAPIManager(cep, address) {
//            
//        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
