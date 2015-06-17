//
//  Report.swift
//  MaCommercial
//
//  Created by iem on 03/06/2015.
//

import Foundation

//MARK: - Report Class
class Report : Entity {
    
    //MARK: - Variables
    var idMeeting: Int
    var label: String
    var date: String
    var subject: String
    var summary: String
    var feedback: String
    var signature: String
    
    //MARK: - Init
    convenience override init(){
        self.init(id: nil, idMeeting: -1, label: "", date: "", subject: "", summary: "", feedback: "", signature: "")
    }
    
    init(id: Int?, idMeeting: Int, label: String, date: String, subject: String, summary: String, feedback: String, signature: String){
        self.idMeeting = idMeeting
        self.label = label
        self.date = date
        self.subject = subject
        self.summary = summary
        self.feedback = feedback
        self.signature = signature
        
        //Super Init
        super.init()
        self.id = id
        
        //Set Keys
        self.Key = [
            kMCWsTableName: "reports",
            kMCWsId: "id",
            kMCWsMeeting: "id_meeting",
            kMCWsLabel: "label",
            kMCWsDate: "date",
            kMCWsSubject: "subject",
            kMCWsSummary: "summary",
            kMCWsFeedback: "feedback",
            kMCWsSignature: "signature"
        ]
    }
    
	//MARK: - Override Functions
    override func fromJSON(data: JSON) -> Report {
        self.id = data[self.Key[kMCWsId]!].intValue
        self.idMeeting = data[self.Key[kMCWsId]!].intValue
        self.label = data[self.Key[kMCWsLabel]!].stringValue
        self.date = data[self.Key[kMCWsDate]!].stringValue
        self.subject = data[self.Key[kMCWsSubject]!].stringValue
        self.summary = data[self.Key[kMCWsSummary]!].stringValue
        self.feedback = data[self.Key[kMCWsFeedback]!].stringValue
        self.signature = data[self.Key[kMCWsSignature]!].stringValue
        
        return self
    }
    
    override func toDictionnary() -> [String : String] {
        var response = [String: String]()
        
        if let id = self.id {
            response[self.Key[kMCWsId]!] = "\(id)"
        }
        
        response[self.Key[kMCWsMeeting]!] = "\(self.idMeeting)"
        response[self.Key[kMCWsLabel]!] = self.label
        response[self.Key[kMCWsDate]!] = self.date
        response[self.Key[kMCWsSubject]!] = self.subject
        response[self.Key[kMCWsSummary]!] = self.summary
        response[self.Key[kMCWsFeedback]!] = self.feedback
        response[self.Key[kMCWsSignature]!] = self.signature
        
        return response
    }
}
