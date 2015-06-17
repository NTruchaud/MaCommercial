//
//  Action.swift
//  MaCommercial
//
//  Created by iem on 03/06/2015.
//  Copyright (c) 2015 Nils Truchaud. All rights reserved.
//

import Foundation

//MARK: - State Enum
enum State{
    case TODO
    case WIP
    case PAUSED
    case VALIDATED
}

//MARK: - Action Class
class Action : Entity {

    //MARK: - Variables
    var label: String
    var description: String
    var creation_date: String
    var goal_date: String
    var state: State
    
    //MARK: - Init
    convenience override  init(){
        self.init(id: nil, label: "", description: "", creation_date: "", goal_date: "", state: .TODO)
    }
    
    init(id: Int?, label: String, description: String, creation_date: String, goal_date: String, state: State){
        self.label = label
        self.description = description
        self.creation_date = creation_date
        self.goal_date = goal_date
        self.state = state
        
        //Super Init
        super.init()
        self.id = id
        
        //Set Keys
        self.Key = [
            kMCWsTableName: "actions",
            kMCWsId: "id",
            kMCWsLabel: "label",
            kMCWsDescription: "description",
            kMCWsCreationDate: "creation_date",
            kMCWsGoalDate: "goal_date",
            kMCWsState: "state"
        ]
    }
}
