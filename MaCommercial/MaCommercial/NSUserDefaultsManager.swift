//
//  NSUserDefaultsManager.swift
//  MaCommercial
//
//  Created by iem on 09/06/2015.
//  Copyright (c) 2015 Sarah LAFORETS. All rights reserved.
//

import Foundation

class NSUserDefaultsManager {
    
    //MARK: - Set Functions
    static func setValue(#key: String, value: AnyObject) -> Bool {
        return setValues(keys: [key], values: [value])
    }
    
    static func setValues(#keys: [String], values: [AnyObject]) -> Bool {
        let userDefaults = NSUserDefaultsManager.getNSUerDefaults()
        for var index = 0; index < keys.count; ++index  {
            userDefaults.setObject(values[index], forKey: keys[index])
        }
        return userDefaults.synchronize()
    }
    
    //MARK: - Get Functions
    static func getValue(#key: String) -> AnyObject? {
        return getValues(keys: [key])[0]
    }
    
    static func getValues(#keys: [String]) -> [AnyObject?] {
        let userDefaults = NSUserDefaultsManager.getNSUerDefaults()
        var returnValues = [AnyObject?]()
        
        for var index = 0; index < keys.count; ++index {
            if let element: AnyObject = userDefaults.objectForKey(keys[index]) {
                returnValues.append(element)
            }
            else {
                returnValues.append(nil)
            }
        }
        
        return returnValues
    }
    
    //MARK: - Remove Functions
    static func removeKey(#key: String) {
        removeKeys(keys: [key])
    }
    
    static func removeKeys(#keys: [String]) {
        let userDefaults = NSUserDefaultsManager.getNSUerDefaults()
        for key in keys {
            userDefaults.removeObjectForKey(key)
        }
    }
    
    //MARK: - Utilities Functions
    static func getNSUerDefaults() -> NSUserDefaults {
      return NSUserDefaults.standardUserDefaults()
    }
}