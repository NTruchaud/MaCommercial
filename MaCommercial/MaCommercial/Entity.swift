//
//  Entity.swift
//  MaCommercial
//
//  Created by iem on 03/06/2015.
//  Copyright (c) 2015 Sarah LAFORETS. All rights reserved.
//

import Foundation

//MARK: - Entity Class
class Entity {
    
    //MARK: - Variables
    var Key : [String: String] = [:]
    var id : Int?
    
    //MARK: - Override functions
    func toDictionnary() -> [String: String] {
        preconditionFailure("This method must be overridden")
    }    
    func fromJSON(data: JSON) -> Entity {
        preconditionFailure("This method must be overridden")
    }
}