//
//  Meeting.swift
//  MaCommercial
//
//  Created by iem on 03/06/2015.
//  Copyright (c) 2015 Sarah LAFORETS. All rights reserved.
//

import Foundation

//MARK: - Meeting Class
class Meeting : Entity {
    
    //MARK: - Variables
    var date: String
    var label: String
    var description: String
    var location: String
    var idIcal: String?
    
    //MARK: - Init
    convenience override init(){
        self.init(id: nil, date: "", label: "", description: "", location: "", idIcal: "")
    }
    
    init(id: Int?, date: String, label: String, description: String, location: String, idIcal: String?){
        self.date = date
        self.label = label
        self.description = description
        self.location = location
        self.idIcal = idIcal
        
        //Super init
        super.init()
        self.id = id
        
        //Set Keys
        self.Key = [
            kMCWsTableName: "meetings",
            kMCWsId: "id",
            kMCWsLabel: "label",
            kMCWsDate: "date",
            kMCWsDescription: "description",
            kMCWsLocation: "location",
            kMCWsIdCal: "id_ical"
        ]
    }
    
    //MARK: - Override Functions
    
    override func fromJSON(data: JSON) -> Meeting {
        self.id = data[self.Key[kMCWsId]!].intValue
        self.date = data[self.Key[kMCWsDate]!].stringValue
        self.label = data[self.Key[kMCWsLabel]!].stringValue
        self.description = data[self.Key[kMCWsDescription]!].stringValue
        self.location = data[self.Key[kMCWsLocation]!].stringValue
        self.idIcal = data[self.Key[kMCWsIdCal]!].stringValue
        
       return self
    }
    
    override func toDictionnary() -> [String : String] {
        var response = [String: String]()
        
        if let id = self.id {
            response[self.Key[kMCWsId]!] = "\(id)"
        }
        
        response[self.Key[kMCWsLabel]!] = self.label
        response[self.Key[kMCWsDate]!] = self.date
        response[self.Key[kMCWsDescription]!] = self.description
        response[self.Key[kMCWsLocation]!] = self.location
        response[self.Key[kMCWsIdCal]!] = self.idIcal
        
        return response
    }
    
}