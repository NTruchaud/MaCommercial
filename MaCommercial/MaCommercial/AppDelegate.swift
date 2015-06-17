//
//  AppDelegate.swift
//  MaCommercial
//
//  Created by Sarah LAFORETS on 02/06/2015.
//  Copyright (c) 2015 Nils Truchaud. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setAppearanceNavigation()
        
        setAppearanceButton()
        
        setCellAppearance()
        
        //setFontColor()
        
        setTabBarAppearance()
        
        //Load good View
        self.window!.hidden = false
        if NSUserDefaultsManager.getValue(key: kMCUserKey) != nil {
            self.window?.rootViewController?.performSegueWithIdentifier("dashboardView", sender: self.window!.rootViewController)
        }
        self.window!.makeKeyWindow()
        return true
    }

    func setAppearanceNavigation() {
        var navigationBarAppearance = UINavigationBar.appearance()
        
        navigationBarAppearance.tintColor = UIColor.whiteColor()
        navigationBarAppearance.barTintColor = kMCColorPrimary
        
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    func setAppearanceButton() {
        var buttonAppearance = UIButton.appearance()
        buttonAppearance.backgroundColor = kMCColorPrimary
        buttonAppearance.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        //Custom Style for Buttons in TableViewCell
        var buttonAppareanceInTableViewCell = UIButton.customAppearanceWhenContainedIn(UITableViewCell.self)
        buttonAppareanceInTableViewCell.backgroundColor = UIColor(white: 0, alpha: 0)
        buttonAppareanceInTableViewCell.tintColor = kMCColorPrimary
    }
    
    func setCellAppearance() {
        var cellAppearance = UITableViewCell.customAppearanceWhenContainedIn(UITableView.self)
        
        // Stylize cell background
        cellAppearance.backgroundColor =  UIColor.clearColor()
        var effect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        var effectStyle = UIVisualEffectView(effect: effect)
        cellAppearance.backgroundView = effectStyle
        
        var cellLabelColor = UILabel.customAppearanceWhenContainedIn(UITableViewCell.self)
        var cellSectionColor = UILabel.customAppearanceWhenContainedIn(UITableViewHeaderFooterView.self)
        cellLabelColor.textColor = UIColor.whiteColor()
        cellSectionColor.textColor = UIColor.whiteColor()
    }
    
    func setTabBarAppearance() {
        var tabBarAppareance = UITabBar.appearance()
        
        tabBarAppareance.barTintColor = kMCColorPrimary
        tabBarAppareance.tintColor = UIColor.whiteColor()
    }
    
}

