//
//  DashboardController.swift
//  MaCommercial
//
//  Created by iem on 04/06/2015.
//  Copyright (c) 2015 Nils Truchaud. All rights reserved.
//

import UIKit

class DashboardController: UIViewController {

    @IBOutlet weak var ivClient: UIImageView!
    @IBOutlet weak var ivAppointment: UIImageView!
    @IBOutlet weak var ivReport: UIImageView!
    @IBOutlet weak var ivContract: UIImageView!
    @IBOutlet weak var ivPresentation: UIImageView!
    
    override func loadView() {
        if UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) {
            self.view = NSBundle.mainBundle().loadNibNamed("DashboardViewPortrait", owner: self, options: nil)[0] as! UIView
            self.view.backgroundColor = UIColor(patternImage: kMCImageOfficeBackground)
        } else {
            self.view = NSBundle.mainBundle().loadNibNamed("DashboardViewLandscape", owner: self, options: nil)[0] as! UIView
            self.view.backgroundColor = UIColor(patternImage: kMCImageOfficeBackground)
        }
        addGesture()
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if UIInterfaceOrientationIsPortrait(toInterfaceOrientation) {
            self.view = NSBundle.mainBundle().loadNibNamed("DashboardViewPortrait", owner: self, options: nil)[0] as! UIView
            self.view.backgroundColor = UIColor(patternImage: kMCImageOfficeBackground)
        } else {
            self.view = NSBundle.mainBundle().loadNibNamed("DashboardViewLandscape", owner: self, options: nil)[0] as! UIView
            self.view.backgroundColor = UIColor(patternImage: kMCImageOfficeBackground)
        }
        addGesture()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        if UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) {
            self.view = NSBundle.mainBundle().loadNibNamed("DashboardViewPortrait", owner: self, options: nil)[0] as! UIView
            self.view.backgroundColor = UIColor(patternImage: kMCImageOfficeBackground)
        } else {
            self.view = NSBundle.mainBundle().loadNibNamed("DashboardViewLandscape", owner: self, options: nil)[0] as! UIView
            self.view.backgroundColor = UIColor(patternImage: kMCImageOfficeBackground)
        }
        addGesture()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("name_app", comment: "")

        // Do any additional setup after loading the view.
        
        addGesture()
        self.view.backgroundColor = UIColor(patternImage: kMCImageOfficeBackground)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        self.loadView()
        self.view.backgroundColor = UIColor(patternImage: kMCImageOfficeBackground)
    }
    
    func addGesture() {
        addGestureAction("clientClick:", onImage: ivClient)
        addGestureAction("appointmentClick:", onImage: ivAppointment)
        addGestureAction("reportClick:", onImage: ivReport)
        addGestureAction("contractClick:", onImage: ivContract)
        addGestureAction("presentationClick:", onImage: ivPresentation)
    }
    
    func addGestureAction(action : Selector, onImage image : UIImageView!){
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        image.addGestureRecognizer(tapGesture)
        image.userInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func clientClick(gesture: UIGestureRecognizer) {
        
        if let imageView = gesture.view as? UIImageView {
            self.performSegueWithIdentifier("contactView", sender: self)		
        }
        
    }
    
    func appointmentClick(gesture: UIGestureRecognizer) {

        if let imageView = gesture.view as? UIImageView {
            self.performSegueWithIdentifier("meetingsView", sender: self)
        }
        
    }
    
    func reportClick(gesture: UIGestureRecognizer) {
        
        if let imageView = gesture.view as? UIImageView {
            self.performSegueWithIdentifier("reportView", sender: self)
        }
        
    }
    
    func contractClick(gesture: UIGestureRecognizer) {
        
        if let imageView = gesture.view as? UIImageView {
            UIAlertView(title: "Contracts", message: "Coming soon...", delegate: nil, cancelButtonTitle: "Cancel").show()
        }
        
    }
    
    func presentationClick(gesture: UIGestureRecognizer) {
        
        if let imageView = gesture.view as? UIImageView {
            self.performSegueWithIdentifier("listPresentationView", sender: self)
        }
        
    }

    //MARK: - Disconnect
    @IBAction func disconnect() {
        //Remove User
        NSUserDefaultsManager.removeKey(key: kMCUserKey)
        
        //Return login
        let appDelegateTemp = UIApplication.sharedApplication().delegate
        let login = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        appDelegateTemp?.window??.rootViewController = login

    }

}
