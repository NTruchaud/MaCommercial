//
//  DataManager.swift
//  MaCommercial
//
//  Created by iem on 03/06/2015.
//  Copyright (c) 2015 Nils Truchaud. All rights reserved.
//

import Foundation

//MARK: - DataManager Class
class DataManager {
        
    //MARK: - Singleton
    class var sharedInstance: DataManager {
        struct Static {
            static let instance: DataManager = DataManager()
        }
        return Static.instance
    
    }
    
    //MARK: - Functions
    func get(entity: Entity, parameters: String?, completionClosure: ((json: JSON?) -> ())?) {
        if let tableName = entity.Key[kMCWsTableName]{
            //Create URL
            var url : String
            if let id = entity.id {
                url = createURL("\(tableName)/\(id)")
            }
            else {
                url = createURL(tableName)
            }
            
            if let params = parameters {
                url += "?" + params
            }
        
            //Request
            request(Method.GET, url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!, parameters: nil, encoding: ParameterEncoding.JSON)
                .responseSwiftyJSON(options: NSJSONReadingOptions.AllowFragments) { (request, response, data, error) -> Void in
                    if let errorValue = error {
                        println("Error (Get): \(errorValue.localizedDescription)")
                        if let closure = completionClosure {
                            closure(json: nil)
                        }
                    }
                    else {
                        if let closure = completionClosure {
                            closure(json: data)
                        }
                    }
            }
        }
        else {
            println("Error (Get): Error on Get TableName")
            if let closure = completionClosure {
                closure(json: nil)
            }
        }
    }
    
    func post(entity: Entity, completionClosure: ((json: JSON?) -> ())?) {
        if let tableName = entity.Key[kMCWsTableName]{
            //Create URL
            var url = createURL(tableName)
            var data = entity.toDictionnary()
            
            //Request
            request(Method.POST, url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!, parameters: data, encoding: ParameterEncoding.JSON)
                .responseSwiftyJSON(options: NSJSONReadingOptions.AllowFragments) { (request, response, data, error) -> Void in
                    if let errorValue = error {
                        println("Error (Post): \(errorValue.localizedDescription)")
                        if let closure = completionClosure {
                            closure(json: nil)
                        }
                    }
                    else {
                        if let closure = completionClosure {
                            closure(json: data)
                        }
                    }
            }
        }
        else {
            println("Error (Post): Error on Get TableName")
            if let closure = completionClosure {
                closure(json: nil)
            }
        }
    }
    
    func put(entity: Entity, completionClosure: ((json: JSON?) -> ())?) {
        if let tableName = entity.Key[kMCWsTableName]{
            //Create URL
            if let id = entity.id {
                var url = createURL("\(tableName)/\(id)")
                var data = entity.toDictionnary()
            
                //Request
                request(Method.PUT, url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!, parameters: data, encoding: ParameterEncoding.JSON)
                    .responseSwiftyJSON(options: NSJSONReadingOptions.AllowFragments) { (request, response, data, error) -> Void in
                        if let errorValue = error {
                            println("Error (Put): \(errorValue.localizedDescription)")
                            if let closure = completionClosure {
                                closure(json: nil)
                            }
                        }
                        else {
                            if let closure = completionClosure {
                                closure(json: data)
                            }
                        }
                }
            }
            else {
                println("Error (Put): Bad id")
                if let closure = completionClosure {
                    closure(json: nil)
                }
            }
        }
        else {
            println("Error (Put): Error on Get TableName")
            if let closure = completionClosure {
                closure(json: nil)
            }
        }
    }
    
    func delete(entity: Entity, completionClosure: ((json: JSON?) -> ())?) {
        if let tableName = entity.Key[kMCWsTableName]{
            //Create URL
            if let id = entity.id {
                var url = createURL("\(tableName)/\(id)")
        
                //Request
                request(Method.DELETE, url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!, parameters: nil, encoding: ParameterEncoding.JSON)
                    .responseSwiftyJSON(options: NSJSONReadingOptions.AllowFragments) { (request, response, data, error) -> Void in
                        if let errorValue = error {
                            println("Error (Delete): \(errorValue.localizedDescription)")
                            if let closure = completionClosure {
                                closure(json: nil)
                            }
                        }
                        else {
                            if let closure = completionClosure {
                                closure(json: data)
                            }
                        }
                }
            }
            else {
                println("Error (Delete): Bad id")
                if let closure = completionClosure {
                    closure(json: nil)
                }
            }
        }
        else {
            println("Error (Delete): Error on Get TableName")
            if let closure = completionClosure {
                closure(json: nil)
            }
        }
    }
    
    internal func createURL(endURL: String) -> String {
        return "\(kMCPathServer)/\(endURL)"
    }
}
