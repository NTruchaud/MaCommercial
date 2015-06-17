//
//  LoginViewController.swift
//  MaCommercial
//
//  Created by iem on 04/06/2015.
//  Copyright (c) 2015 Nils Truchaud. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var logoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init loader
        loader = Loader(view: self.view)
        
        self.view.backgroundColor = UIColor(patternImage: kMCImageDesign)
        self.loginBtn.backgroundColor = UIColor(white: 0, alpha: 0)
        self.logoLabel.textColor = UIColor(red: 170, green: 0, blue: 0, alpha: 0.7)
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    @IBAction func loginAction(sender: AnyObject) {
        loader?.showLoader()
        if emailTextField.text == "" || passwordTextField.text == "" {
            self.showErrorMessage(NSLocalizedString("login_error_no_email_and_password", comment: ""))
        }
        else {
            var user = User()
            
            let emailText = emailTextField.text.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
            let passwordTest = passwordTextField.text.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
            
            var params = "\(user.Key[kMCWsEmail]!)=\(emailText!)&\(user.Key[kMCWsPassword]!)=\(passwordTest!)"
            DataManager.sharedInstance.get(user, parameters: params, completionClosure: { (json) -> () in
                loader?.hideLoader()
                if let data = json {
                    if ((data[0][user.Key[kMCWsEmail]!].string != nil) && (data[0][user.Key[kMCWsPassword]!].string) != nil) {
                        if NSUserDefaultsManager.setValue(key: kMCUserKey, value: data[0].object) == true {
                            println("User has been saved")
                        }
                        self.performSegueWithIdentifier("dashboardView", sender: self)
                    }
                    else {
                        self.showErrorMessage(NSLocalizedString("login_error_bad_email_or_password", comment: ""))
                    }
                }
                else {
                    self.showErrorMessage(NSLocalizedString("login_error_bad_email_or_password", comment: ""))
                }
            })
        }
    }
    
    func showErrorMessage(message: String) {
        TSMessage.showNotificationInViewController(self, title: message, subtitle: "", type: TSMessageNotificationType.Error, duration: NSTimeInterval(500))
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return false
    }
    
    //MARK : - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1;
        let nextResponder = textField.superview?.viewWithTag(nextTag)
        if ((nextResponder) != nil) {
            nextResponder?.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            self.loginAction(self)
        }
        return false;
    }
    
    //MARK: - Notification Keyboard
    var up = false
    func keyboardWillShow(sender: NSNotification) {
        if up == false {
            self.view.frame.origin.y -= kMCUpForKeyboard
            up = true
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if up == true {
            self.view.frame.origin.y += kMCUpForKeyboard
            up = false
        }
    }
    
}
