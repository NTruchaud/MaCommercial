//
//  Loader.swift
//  MaCommercial
//
//  Created by iem on 08/06/2015.
//  Copyright (c) 2015 Sarah LAFORETS. All rights reserved.
//

import Foundation
import UIKit

class Loader {
    //MARK: - Variables
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    var loadingView: UIView = UIView()
    var started = false
    var view: UIView?
    
    //MARK: - Constructor
    init(view: UIView) {
        self.view = view
    }
    
    //MARK: - Functions
    func showLoader() {
        if let currentView = view {
            dispatch_async(dispatch_get_main_queue()) {
                //Init Loading View
                self.loadingView = UIView()
                self.loadingView.frame = currentView.frame
                self.loadingView.center = currentView.center
                self.loadingView.backgroundColor = UIColor.grayColor()
                self.loadingView.alpha = 0.7
                self.loadingView.clipsToBounds = true
                
                //Init spinner
                self.spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
                self.spinner.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
                self.spinner.center = CGPoint(x:self.loadingView.bounds.size.width / 2, y:self.loadingView.bounds.size.height / 2)
                
                //Start
                self.loadingView.addSubview(self.spinner)
                currentView.addSubview(self.loadingView)
                self.spinner.startAnimating()
                
                //Set Start
                self.started = true
            }
        }
    }
    
    func hideLoader() {
        if self.started {
            dispatch_async(dispatch_get_main_queue()) {
                //Stop Spinner
                self.spinner.stopAnimating()
                
                //Remove View
                self.loadingView.removeFromSuperview()
                
                //Set Start
                self.started = false
            }
        }
    }    
}