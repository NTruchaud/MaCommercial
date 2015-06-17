//
//  Participant.swift
//  MaCommercial
//
//  Created by Sarah LAFORETS on 08/06/2015.
//

import Foundation

//MARK: - Participant Class
class Participant : Entity {
    
    //MARK: - Variables
    var id_meeting : Int
    var id_user :Int
    
    //MARK: - Init
    convenience override init(){
        self.init(id: nil, id_meeting: 0, id_user: 0)
    }
    
    init(id: Int?, id_meeting: Int, id_user: Int){
        
        self.id_meeting = id_meeting
        self.id_user = id_user
        
        //Super Init
        super.init()
        self.id = id
        
        //Set Keys
        self.Key = [
            kMCWsTableName: "participants",
            kMCWsId: "id",
            kMCWsUser: "id_user",
            kMCWsMeeting: "id_meeting"
        ]
    }
    
    //MARK: - Override Functions
    override func fromJSON(data: JSON) -> Participant {
        self.id = data[self.Key[kMCWsId]!].intValue
        self.id_meeting = data[self.Key[kMCWsMeeting]!].stringValue.toInt()!
        self.id_user = data[self.Key[kMCWsUser]!].stringValue.toInt()!
        
        return self
    }
    
    override func toDictionnary() -> [String : String] {
        var response = [String: String]()
        
        if let id = self.id {
            response[self.Key[kMCWsId]!] = "\(id)"
        }
        
        response[self.Key[kMCWsMeeting]!] = "\(self.id_meeting)"
        response[self.Key[kMCWsUser]!] = "\(self.id_user)"
        
        
        return response
    }
    
    //MARK: - Functions
    class func getMeetingsForUser(user: User, completionClosure: (meeting: Meeting) -> ()){
        var entity: Participant = Participant()
        
        // Foreach users get meetings
        var params: String = "id_user=\(user.id!)"
        
        DataManager.sharedInstance.get(entity, parameters: params) { (json) -> () in
            if let data = json {
                var subParams = ""
                for (key, participantJSon) in data {
                    var participant: Participant = Participant()
                    participant.fromJSON(participantJSon)
                    
                    subParams = "id=\(participant.id_meeting)"
                    
                    var subEntity: Meeting = Meeting()
                    DataManager.sharedInstance.get(subEntity, parameters: subParams, completionClosure: { (json) -> () in
                        var meetings:[Meeting] = [Meeting]()
                        
                        if let data = json {
                            for (key, meetingJSon) in data {
                                var meeting: Meeting = Meeting()
                                meeting.fromJSON(meetingJSon)
                                
                                completionClosure(meeting: meeting)
                            }
                        }
                    })
                }
            }
        }
    }
    
    class func getUsersForMeeting(meeting: Meeting, completionClosure: (user: User) -> ()) {
        var entity: Participant = Participant()
        
        // Foreach users get meetings
        var params: String = "id_meeting=\(meeting.id!)"
        
        DataManager.sharedInstance.get(entity, parameters: params) { (json) -> () in
            if let data = json {
                var subParams = ""
                for (key, participantJSon) in data {
                    var participant: Participant = Participant()
                    participant.fromJSON(participantJSon)
                    
                    subParams = "id=\(participant.id_user)"
                    
                    var subEntity: User = User()
                    DataManager.sharedInstance.get(subEntity, parameters: subParams, completionClosure: { (json) -> () in
                        var users:[User] = [User]()
                        
                        if let data = json {
                            for (key, userJSon) in data {
                                var user: User = User()
                                user.fromJSON(userJSon)
                                
                                completionClosure(user: user)
                            }
                        }
                    })
                }
            }
        }
    }
    
    class func addUsers(users: [User], inMeeting meeting: Meeting) {
        for user in users {
            var participant: Participant = Participant(id: nil, id_meeting: meeting.id!, id_user: user.id!)
            var params = "id_meeting=\(participant.id_meeting)&id_user=\(participant.id_user)"
            DataManager.sharedInstance.get(participant, parameters: params, completionClosure: { (json) -> () in
                if let data: JSON = json {
                    if data.count == 0 {
                        DataManager.sharedInstance.post(participant, completionClosure: { (_) -> () in })
                    }
                }
            })
        }
    }
    
    class func removeUsers(users: [User], inMeeting meeting: Meeting) {
        for user in users {
            var participant: Participant = Participant(id: nil, id_meeting: meeting.id!, id_user: user.id!)
            var params = "id_meeting=\(participant.id_meeting)&id_user=\(participant.id_user)"
            DataManager.sharedInstance.get(participant, parameters: params, completionClosure: { (json) -> () in
                if let data = json {
                    for (key, jsonItem) in data {
                        var participantReceive: Participant = Participant()
                        participantReceive.fromJSON(jsonItem)
                        
                        DataManager.sharedInstance.delete(participantReceive, completionClosure: { (_) -> () in })
                    }
                }
            })
        }
    }
    
    class func addMeetings(meetings: [Meeting], inUser user: User) {
        for meeting in meetings {
            var participant: Participant = Participant(id: nil, id_meeting: meeting.id!, id_user: user.id!)
            var params = "id_meeting=\(participant.id_meeting)&id_user=\(participant.id_user)"
            DataManager.sharedInstance.get(participant, parameters: params, completionClosure: { (json) -> () in
                if let data = json {
                    if data == "" {
                        DataManager.sharedInstance.post(participant, completionClosure: { (_) -> () in })
                    }
                }
            })
            
        }
    }
    
    class func removeMeetings(meetings: [Meeting], inUser user: User) {
        for meeting in meetings {
            var participant: Participant = Participant(id: nil, id_meeting: meeting.id!, id_user: user.id!)
            var params = "id_meeting=\(participant.id_meeting)&id_user=\(participant.id_user)"
            DataManager.sharedInstance.get(participant, parameters: params, completionClosure: { (json) -> () in
                if let data = json {
                    for (key, jsonItem) in data {
                        var participantReceive: Participant = Participant()
                        participantReceive.fromJSON(jsonItem)
                        
                        DataManager.sharedInstance.delete(participantReceive, completionClosure: { (_) -> () in })
                    }
                }
            })
        }
    }
    
    class func removeParticpantsInMeeting(meeting: Meeting) {
    
            var participant: Participant = Participant(id: nil, id_meeting: meeting.id!, id_user: 0)
            var params = "id_meeting=\(participant.id_meeting)"
            DataManager.sharedInstance.get(participant, parameters: params, completionClosure: { (json) -> () in
                if let data = json {
                    for (key, jsonItem) in data {
                        var participantReceive: Participant = Participant()
                        participantReceive.fromJSON(jsonItem)
                        
                        DataManager.sharedInstance.delete(participantReceive, completionClosure: { (_) -> () in })
                    }
                }
            })
    }
    
    class func removeMeetingForParticipant(user: User) {
        
        var participant: Participant = Participant(id: nil, id_meeting: 0, id_user: user.id!)
        var params = "id_user=\(participant.id_user)"
        DataManager.sharedInstance.get(participant, parameters: params, completionClosure: { (json) -> () in
            if let data = json {
                for (key, jsonItem) in data {
                    var participantReceive: Participant = Participant()
                    participantReceive.fromJSON(jsonItem)
                    
                    DataManager.sharedInstance.delete(participantReceive, completionClosure: { (_) -> () in })
                }
            }
        })
    }

    
    // MARK - Template
    /*
    var entity:User = User()
    DataManager.sharedInstance.get(entity, parameters: nil) { (json) -> () in
        if let data = json {
            for (key, userJson) in data{
                var user:User = User()
                user.fromJSON(userJson)
    
                Participant.getMeetingsForUser(user, completionClosure: { (meeting) -> () in
                    print(meeting.label)
                })
            }
        }
    }
    
    var entity2:Meeting = Meeting()
    DataManager.sharedInstance.get(entity2, parameters: nil) { (json) -> () in
        if let data = json {
            for (key, meetingJson) in data{
                var meeting:Meeting = Meeting()
                meeting.fromJSON(meetingJson)
    
                Participant.getUsersForMeeting(meeting, completionClosure: { (user) -> () in
                print(user.first_name)
                })
            }
        }
    }
    
    var meetings: [Meeting] = [Meeting(id: 3, date: "", label: "", description: "", location: "")]
    var user: User = User(id: 2, last_name: "", first_name: "", email: "", password: "", cell_number: "", company: "", job: "", picture: "", postal_address: "", home_number: "", birth_date: "", type: TypeUser.CLIENT)
    Participant.addMeetings(meetings, inUser: user)
    Participant.removeMeetings(meetings, inUser: user)
    */
}
