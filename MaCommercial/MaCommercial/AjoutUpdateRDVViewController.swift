//
//  AjoutUpdateRDVViewController.swift
//  MaCommercial
//
//  Created by Sarah LAFORETS on 04/06/2015.
//  Copyright (c) 2015 Nils Truchaud. All rights reserved.
//

import UIKit
import MapKit
import EventKit
import Foundation

class AjoutUpdateRDVViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPopoverControllerDelegate {
    
    //MARK: - Variables storyboard
    
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet var mapViewLocation: MKMapView!
    @IBOutlet var labelTitle: UITextField!
    @IBOutlet var labelDate: UITextField!
    @IBOutlet var tvDescription: UITextView!
    @IBOutlet var labelLocation: UITextField!
    @IBOutlet var labelParticipants: UITextField!
    @IBOutlet var tabViewParticipant: UITableView!
    
    //MARK: - Variables locales
    
    var users: [User] = []
    var usersSelected: [User] = []
    var participants: [User] = []
    var autocompleteTableView: UITableView!
    var cellAutocomplete: UITableViewCell!
    var savedEventId: String?
    var loader:Loader?
    
    var popDatePicker: PopDatePicker?
    var popoverView: UIPopoverController?
    
    
    //MARK: - ViewLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init loader
        loader = Loader(view: self.view)
        
        // Change font color
        self.labelDate.textColor = UIColor.blackColor()
        self.labelLocation.textColor = UIColor.blackColor()
        self.labelParticipants.textColor = UIColor.blackColor()
        self.labelTitle.textColor = UIColor.blackColor()
        
        
        self.view.backgroundColor = UIColor(patternImage: kMCImageOfficeBackground)

        
        // Set all delegate
        autocompleteTableView = UITableView(frame: CGRectMake(labelParticipants.frame.origin.x + 65,labelParticipants.frame.origin.y + labelParticipants.frame.size.width - 20,320,labelParticipants.frame.size.width), style: UITableViewStyle.Plain)
        cellAutocomplete = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "AutoCompleteRowIdentifier")
        
        autocompleteTableView.registerClass(cellAutocomplete.classForCoder, forCellReuseIdentifier: "AutoCompleteRowIdentifier")
        
        autocompleteTableView.delegate = self
        autocompleteTableView.dataSource = self
        autocompleteTableView.scrollEnabled = true
        autocompleteTableView.hidden = true
        
        tabViewParticipant.delegate = self
        tabViewParticipant.dataSource = self
        tabViewParticipant.scrollEnabled = true
        
        labelParticipants.delegate = self
        
        //DatePicker
        
        popDatePicker = PopDatePicker(forTextField: labelDate)
        labelDate.delegate = self
        
        // Add tableView
        self.view.addSubview(autocompleteTableView)
        
        //Charge all users in user[]
        initAllUser()
        
        //Init popover
        initPopover()
        
        // Add title to the view
        self.title = NSLocalizedString("meeting_add_update_title", comment: "")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "saveMeeting")
        
        // Set the location
        let location = "1 Infinity Loop, Cupertino, CA"
        var geocoder:CLGeocoder = CLGeocoder()
        
        // Initialize mapView
        geocoder.geocodeAddressString(location, completionHandler: {(placemarks, error) -> Void in
            
            if((error) != nil){
                
                println("Error", error)
            }
                
            else if let placemark = placemarks?[0] as? CLPlacemark {
                
                var placemark:CLPlacemark = placemarks[0] as! CLPlacemark
                var coordinates:CLLocationCoordinate2D = placemark.location.coordinate
                
                // Put a annotation
                var pointAnnotation:MKPointAnnotation = MKPointAnnotation()
                pointAnnotation.coordinate = coordinates
                pointAnnotation.title = "Apple HQ"
                
                self.mapViewLocation?.addAnnotation(pointAnnotation)
                self.mapViewLocation?.centerCoordinate = coordinates
                self.mapViewLocation?.selectAnnotation(pointAnnotation, animated: true)
                
                println("Added annotation to map view")
            }
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation


    //MARK: - Init data
    
    func initAllUser() {
        var entityUser: User = User()
        DataManager.sharedInstance.get(entityUser, parameters: nil) { (json) -> () in
            if json != nil {
                for (key, data) in json! {
                    var user: User = User()
                    user.fromJSON(data)
                    self.users.append(user)
                }
            }
        }
    }
    
    //MARK: - Textfield data source
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == labelParticipants {
            
            var substring = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
            
            searchAutocompleteEntriesWithSubstring(substring)
        }
        return true     // not sure about this - could be false
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if (textField === labelDate) {
            resign()
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            formatter.timeStyle = .NoStyle
            let initDate : NSDate? = formatter.dateFromString(labelDate.text)
            let dataChangedCallback : PopDatePicker.PopDatePickerCallback = { (newDate : NSDate, forTextField : UITextField) -> () in
                // here we don't use self (no retain cycle)
                let dateFormat = NSDateFormatter()
                dateFormat.dateFormat = "dd/MM/yyyy"
                forTextField.text = dateFormat.stringFromDate(newDate)
            }
            popDatePicker!.pick(self, initDate: initDate, dataChanged: dataChangedCallback)
            return false
        }
        else {
            return true
        }
    }
    
    //MARK: - Autocomplete function
    
    func searchAutocompleteEntriesWithSubstring(substring: String) {
        self.usersSelected.removeAll(keepCapacity: false)
        
        for user in users {
            var myUser:User! = user as User
            
            var userString: NSString = "\(user.first_name.lowercaseString) \(user.last_name.lowercaseString)"
            
            if (userString.containsString(substring.lowercaseString)) {
                autocompleteTableView.hidden = false
                usersSelected.append(user)
            }
        }
        if (!(labelParticipants.text.isEmpty) && (usersSelected.count == 0)) || (usersSelected.count == 0){
            self.addPopOver()
        } else {
            self.dismissPopover()
        }
        autocompleteTableView.reloadData()
    }
    
    //MARK: - TableView Data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tabViewParticipant {
            return participants.count
        } else {
            return usersSelected.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        if tableView == tabViewParticipant {
            let autoCompleteRowIdentifier = "participantCell"
            cell = tableView.dequeueReusableCellWithIdentifier(autoCompleteRowIdentifier, forIndexPath: indexPath) as! UITableViewCell
            let index = indexPath.row as Int
            
            cell.textLabel!.text = participants[index].last_name + " " + participants[index].first_name
        } else {
            let autoCompleteRowIdentifier = "AutoCompleteRowIdentifier"
            cell = tableView.dequeueReusableCellWithIdentifier(autoCompleteRowIdentifier, forIndexPath: indexPath) as! UITableViewCell
            let index = indexPath.row as Int
            
            cell.textLabel!.text = usersSelected[index].last_name + " " + usersSelected[index].first_name
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == autocompleteTableView {
            var aUser = usersSelected[indexPath.row] as User
            participants.append(aUser)
            autocompleteTableView.hidden = true
            labelParticipants.text = ""
            tabViewParticipant.reloadData()
        }
    }
    
    
    
    //MARK: - Save Meeting
    
    
    func saveMeeting() {
        loader?.showLoader()
        var title = labelTitle.text
        var date = labelDate.text
        var description = tvDescription.text
        var location = labelLocation.text
        addInICalendar(title, date: date, description: description, location: location) { (idCal) -> () in
            var meeting = Meeting(id: nil, date: date, label: title, description: description, location: location, idIcal: idCal)
            
            DataManager.sharedInstance.post(meeting, completionClosure: { (json) -> () in
                if json == nil {
                    println("error")
                } else {
                    var theMeeting: Meeting = Meeting()
                    theMeeting.fromJSON(json!)
                    
                    if self.participants.count != 0 {
                        Participant.addUsers(self.participants, inMeeting: theMeeting)
                    }
                    
                    if let navigationController = self.navigationController {
                        navigationController.popViewControllerAnimated(true)
                    }

                }
                self.loader?.hideLoader()
            })
        }
    }
    
    //MARK: - Date picker
    
    func resign() {
        self.labelDate.resignFirstResponder()
    }
    
    //MARK: - Add in calendar
    
    func addInICalendar(title: String, date: String, description: String, location: String?, closure:(String) -> ()) {
        let store = EKEventStore()
        var id: String = ""
        store.requestAccessToEntityType(EKEntityTypeEvent) { (granted, error) in
            if !granted {
                println("Granted")
                return
            }
            var event = EKEvent(eventStore: store)
            event.title = title
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let mDate = dateFormatter.dateFromString(date)
            event.location = location
            event.startDate = mDate
            event.endDate = event.startDate.dateByAddingTimeInterval(60*60) //1 hour long meeting
            event.calendar = store.defaultCalendarForNewEvents
            var err: NSError?
            store.saveEvent(event, span: EKSpanThisEvent, commit: true, error: &err)
            self.savedEventId = event.eventIdentifier //save event id to access this particular event later
            id = event.eventIdentifier
            closure(id)
        }
    }
    
    //MARK: - PopOver
    
    func initPopover() {
        let storyboard : UIStoryboard = UIStoryboard(
            name: "Main",
            bundle: nil)
        var popoverContent: UIViewController = storyboard.instantiateViewControllerWithIdentifier("popOverParticipant") as! UIViewController
        popoverView = UIPopoverController(contentViewController: popoverContent)
        popoverView!.delegate = self
    }
    
    func addPopOver() {
        
        var rect: CGRect = CGRectMake(labelParticipants.frame.origin.x + (labelParticipants.frame.size.width/2),labelParticipants.frame.origin.y,0,0)
        popoverView!.presentPopoverFromRect(rect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Down, animated: true)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func dismissPopover() {
        popoverView!.dismissPopoverAnimated(true)
    }
}
