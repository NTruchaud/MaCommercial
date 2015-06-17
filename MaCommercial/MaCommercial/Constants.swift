//
//  Constants.swift
//  MaCommercial
//
//  Created by iem on 03/06/2015.
//  Copyright (c) 2015 Sarah LAFORETS. All rights reserved.
//

import Foundation

/** NSUserDefault **/
var kMCUserKey : String { return "userDefaultMCKeyUser" }

/*** Design ***/
var kMCColorPrimary : UIColor { return UIColor(red: 170.0/255, green: 0, blue: 0, alpha: 1) }
var kMCImageDesign : UIImage { return UIImage(named: "businessman_background.jpg")! }
var kMCImageOfficeBackground : UIImage { return UIImage(named: "background_blur.jpg")! }
var kMCImageCarsBackground : UIImage { return UIImage(named: "background_meetings.jpg")! }
var kMCUpForKeyboard : CGFloat { return 100 }

/*** WebServices Key ***/
var kMCPath : String { return "http://52.24.51.145" }
var kMCPathServer : String { return "\(kMCPath)/server" }
var kMCPathResources : String { return kMCPath }
var kMCPathUpload : String { return "\(kMCPath)/upload" }

var kMCWsTableName : String { return "TABLE_NAME" }
var kMCWsId : String { return "ID" }

var kMCWsLabel : String { return "LABEL" }
var kMCWsDescription : String { return "DESCRIPTION" }
var kMCWsCreationDate : String { return "CREATION_DATE" }
var kMCWsGoalDate : String { return "GOAL_DATE" }
var kMCWsState : String { return "STATE" }
var kMCWsDate : String { return "DATE" }
var kMCWsLocation : String { return "LOCATION" }
var kMCWsParticipants : String { return "PARTICIPANTS" }
var kMCWsTitle : String { return "TITLE" }
var kMCWsUpdate : String { return "UPDATE" }
var kMCWsDocument : String { return "DOCUMENT" }
var kMCWsSubject : String { return "SUBJECT" }
var kMCWsSummary : String { return "SUMMARY" }
var kMCWsFeedback : String { return "FEEDBACK" }
var kMCWsSignature : String { return "SIGNATURE" }
var kMCWsLastName : String { return "LAST_NAME" }
var kMCWsFirstName : String { return "FIRST_NAME" }
var kMCWsEmail : String { return "EMAIL" }
var kMCWsPassword : String { return "PASSWORD" }
var kMCWsCellNumber : String { return "CELL_NUMBER" }
var kMCWsCompany : String { return "COMPANY" }
var kMCWsJob : String { return "JOB" }
var kMCWsPicture : String { return "PICTURE" }
var kMCWsPostalAdress : String { return "POSTAL_ADDRESS" }
var kMCWsHomeNumber : String { return "HOME_NUMBER" }
var kMCWsBirthDate : String { return "BIRTH_DATE" }
var kMCWsType : String { return "TYPE" }
var kMCWsUser : String { return "USER" }
var kMCWsMeeting : String { return "MEETING" }
var kMCWsIdCal: String { return "IDCAL"}
