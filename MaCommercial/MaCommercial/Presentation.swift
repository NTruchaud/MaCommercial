//
//  Presentation.swift
//  MaCommercial
//
//  Created by iem on 03/06/2015.
//  Copyright (c) 2015 Sarah LAFORETS. All rights reserved.
//

import Foundation

//MARK: - Presentation Class
class Presentation : Entity {
    
    //MARK: - Variables
    var title: String
    var description: String
    var update: String
    var document: String
    
    //MARK: - Init
    convenience override init(){
        self.init(id: nil, title: "", description: "", update: "", document: "")
    }
    
    init(id: Int?, title: String, description: String, update: String, document: String){
        self.title = title
        self.description = description
        self.update = update
        self.document = document
        
        //Super Init
        super.init()
        self.id = id
        
        //Set Keys
        self.Key = [
            kMCWsTableName: "presentations",
            kMCWsId: "id",
            kMCWsTitle: "title",
            kMCWsDescription: "description",
            kMCWsUpdate: "update",
            kMCWsDocument: "document"
        ]
    }
    
    //MARK: - Override Functions
    override func fromJSON(data: JSON) -> Presentation {
        self.id = data[self.Key[kMCWsId]!].intValue
        self.title = data[self.Key[kMCWsTitle]!].stringValue
        self.description = data[self.Key[kMCWsDescription]!].stringValue
        self.update = data[self.Key[kMCWsUpdate]!].stringValue
        self.document = kMCPathResources + data[self.Key[kMCWsDocument]!].stringValue
        
        return self
    }
}