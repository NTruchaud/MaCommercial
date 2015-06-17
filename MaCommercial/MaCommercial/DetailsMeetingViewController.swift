//
//  DetailsMeetingViewController.swift
//  MaCommercial
//
//  Created by Sarah LAFORETS on 08/06/2015.
//  Copyright (c) 2015 Nils Truchaud. All rights reserved.
//

import UIKit
import MapKit
import EventKit
import Foundation

class DetailsMeetingViewController: UIViewController, SWTableViewCellDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPopoverControllerDelegate {

    //MARK: - Variables
    
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet var mapViewLocation: MKMapView!
    @IBOutlet var labelDateMeeting: UITextField!
    @IBOutlet var labelMeeting: UITextField!
    @IBOutlet var labelLocation: UITextField!
    @IBOutlet var textViewDescription: UITextView!
    @IBOutlet var tabViewParticipant: UITableView!
    @IBOutlet var textFieldParticipant: UITextField!
    
    var meeting: Meeting?
    var users: [User] = []
    var usersSelected: [User] = []
    var participants: [User] = []
    var autocompleteTableView: UITableView!
    var cellAutocomplete: ParticipantTableViewCell!
    
    var popDatePicker: PopDatePicker?
    var popoverView: UIPopoverController?
    
    var loader: Loader?
    
    func rightButtons() -> NSArray {
        var rightUtilityButtons: NSMutableArray = NSMutableArray()
        
        rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 170, green: 0, blue: 0, alpha: 1), icon: UIImage(named: "DeleteWhite50"))
        return rightUtilityButtons
    }
    
    //MARK: - ViewLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init loader
        loader = Loader(view: self.view)
        
        // Init participants
        initParticipant()
        
        //Charge all users in user[]
        initAllUser()
        
        self.view.backgroundColor = UIColor(patternImage: kMCImageOfficeBackground)
        
        self.labelMeeting.textColor = UIColor.whiteColor()
        self.labelDateMeeting.textColor = UIColor.whiteColor()
        self.labelLocation.textColor = UIColor.whiteColor()
        self.textViewDescription.textColor = UIColor.whiteColor()
        self.textFieldParticipant.textColor = UIColor.whiteColor()
        self.labelDescription.textColor = UIColor.whiteColor()
        
        
        // Set all delegate
        autocompleteTableView = UITableView(frame: CGRectMake(textFieldParticipant.frame.origin.x + 65,textFieldParticipant.frame.origin.y + textFieldParticipant.frame.size.width - 20,320,textFieldParticipant.frame.size.width), style: UITableViewStyle.Plain)
        cellAutocomplete = ParticipantTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "AutoCompleteRowIdentifier")
        
        autocompleteTableView.registerClass(cellAutocomplete.classForCoder, forCellReuseIdentifier: "AutoCompleteRowIdentifier")
        
        autocompleteTableView.delegate = self
        autocompleteTableView.dataSource = self
        autocompleteTableView.scrollEnabled = true
        autocompleteTableView.hidden = true
        
        tabViewParticipant.delegate = self
        tabViewParticipant.dataSource = self
        tabViewParticipant.scrollEnabled = true
        
        textFieldParticipant.delegate = self
        
        //DatePicker
        
        self.popDatePicker = PopDatePicker(forTextField: labelDateMeeting)
        labelDateMeeting.delegate = self
        
        // Add tableView
        self.view.addSubview(autocompleteTableView)
        
        // Init popover
        initPopover()
        
        // Add title to the view
        self.title = NSLocalizedString("meeting_detail_title", comment: "")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "updateMeeting")
        
        // Init field with meeting's values
        self.labelMeeting.text = meeting?.label
        self.labelDateMeeting.text = meeting?.date
        self.labelLocation.text = meeting?.location
        self.textViewDescription.text = meeting?.description
        self.textFieldParticipant.hidden = true
        
        // Set the location
        let location = meeting?.location
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
                pointAnnotation.title = self.meeting?.label
                
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Custom function
    func updateMeeting() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "saveMeeting")
        self.labelMeeting.enabled = true
        self.labelDateMeeting.enabled = true
        self.labelLocation.enabled = true
        self.textViewDescription.editable = true
        self.textFieldParticipant.hidden = false
        
        self.labelMeeting.backgroundColor = UIColor.whiteColor()
        self.labelDateMeeting.backgroundColor = UIColor.whiteColor()
        self.labelLocation.backgroundColor = UIColor.whiteColor()
        self.textViewDescription.backgroundColor = UIColor.whiteColor()
        self.textFieldParticipant.backgroundColor = UIColor.whiteColor()
       
        self.labelMeeting.textColor = UIColor.blackColor()
        self.labelDateMeeting.textColor = UIColor.blackColor()
        self.labelLocation.textColor = UIColor.blackColor()
        self.textViewDescription.textColor = UIColor.blackColor()
        self.textFieldParticipant.textColor = UIColor.blackColor()
        
        self.labelMeeting.borderStyle = UITextBorderStyle.RoundedRect
        self.labelDateMeeting.borderStyle = UITextBorderStyle.RoundedRect
        self.labelLocation.borderStyle = UITextBorderStyle.RoundedRect
        //self.textViewDescription.borderStyle = UITextBorderStyle.RoundedRect
        self.textFieldParticipant.borderStyle = UITextBorderStyle.RoundedRect
        
        
    }
    
    func initParticipant() {
        Participant.getUsersForMeeting(self.meeting!, completionClosure: { (user) -> () in
            //print(user.first_name)
            self.participants.append(user)
            self.tabViewParticipant.reloadData()
        })
        
    }
    
    //MARK: - Textfield data source
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == textFieldParticipant {
            
            var substring = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
            
            searchAutocompleteEntriesWithSubstring(substring)
        }
        return true     // not sure about this - could be false
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if (textField === labelDateMeeting) {
            resign()
            
            let dateFormat = NSDateFormatter()
            dateFormat.dateFormat = "dd/MM/yyyy"
            
            var initDate: NSDate = NSDate()
            if labelDateMeeting.text != "" {
                initDate = dateFormat.dateFromString(labelDateMeeting.text)!
            }
            let dataChangedCallback : PopDatePicker.PopDatePickerCallback = { (newDate : NSDate, forTextField : UITextField) -> () in
                // here we don't use self (no retain cycle)
                forTextField.text = dateFormat.stringFromDate(newDate)
            }
            popDatePicker!.pick(self, initDate: initDate, dataChanged: dataChangedCallback)
            return false
        }
        else {
            return true
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            
            var selectedMeeting: [Meeting] = []
            var user: User = self.participants[indexPath.row]
            selectedMeeting.append(self.meeting!)
            
            Participant.removeMeetings(selectedMeeting, inUser: user)
            self.participants.removeAtIndex(indexPath.row)
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
        if (!(textFieldParticipant.text.isEmpty) && (usersSelected.count == 0)) || (usersSelected.count == 0){
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
        var cell : ParticipantTableViewCell!
        if tableView == tabViewParticipant {
            let autoCompleteRowIdentifier = "participantCell"
            cell = tableView.dequeueReusableCellWithIdentifier(autoCompleteRowIdentifier, forIndexPath: indexPath) as! ParticipantTableViewCell
            let index = indexPath.row as Int
            
            cell.textLabel!.text = participants[index].last_name + " " + participants[index].first_name
            println(participants[index].last_name)
            
        } else {
            let autoCompleteRowIdentifier = "AutoCompleteRowIdentifier"
            cell = tableView.dequeueReusableCellWithIdentifier(autoCompleteRowIdentifier, forIndexPath: indexPath) as! ParticipantTableViewCell
            let index = indexPath.row as Int
            
            cell.textLabel!.text = usersSelected[index].last_name + " " + usersSelected[index].first_name
        }
        
        cell.delegate = self
        cell.rightUtilityButtons = self.rightButtons() as [AnyObject]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == autocompleteTableView {
            var aUser = usersSelected[indexPath.row] as User
            participants.append(aUser)
            autocompleteTableView.hidden = true
            textFieldParticipant.text = ""
            tabViewParticipant.reloadData()
        }
    }
    
    // MARK: - SWTableViewCell
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        switch (index) {
        case 0:
            // Report button was pressed
            var selectedMeeting: [Meeting] = []
            var indexPAth = self.tabViewParticipant.indexPathForCell(cell)!
            var indexPathRow = indexPAth.row
            var user: User = self.participants[indexPathRow]
            selectedMeeting.append(self.meeting!)
            
            Participant.removeMeetings(selectedMeeting, inUser: user)
            self.participants.removeAtIndex(index)
            self.tabViewParticipant.reloadData()
            break;
        default:
            break;
        }
    }
    
    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
        return true
    }
    
    //MARK: - Save Meeting
    
    func saveMeeting() {
        loader?.showLoader()
        var title = labelMeeting.text
        var date = labelDateMeeting.text
        var description = textViewDescription.text
        var location = labelLocation.text
        upDateInICalendar(title, date: date, description: description, location: location, idCal: self.meeting!.idIcal!) { (id) -> () in
        
            self.meeting = Meeting(id: self.meeting?.id!, date: date, label: title, description: description, location: location, idIcal: id)
            
            DataManager.sharedInstance.put(self.meeting!, completionClosure: { (json) -> () in
                if json == nil {
                    println("error")
                } else {
                    var theMeeting: Meeting = Meeting()
                    theMeeting.fromJSON(json!)
                    Participant.addUsers(self.participants, inMeeting: theMeeting)
                    
                    self.labelMeeting.enabled = false
                    self.labelDateMeeting.enabled = false
                    self.labelLocation.enabled = false
                    self.textViewDescription.editable = false
                    self.textFieldParticipant.hidden = true
                    
                    self.labelMeeting.backgroundColor = UIColor.clearColor()
                    self.labelDateMeeting.backgroundColor = UIColor.clearColor()
                    self.labelLocation.backgroundColor = UIColor.clearColor()
                    self.textViewDescription.backgroundColor = UIColor.clearColor()
                    self.textFieldParticipant.backgroundColor = UIColor.clearColor()
                    
                    self.labelMeeting.textColor = UIColor.whiteColor()
                    self.labelDateMeeting.textColor = UIColor.whiteColor()
                    self.labelLocation.textColor = UIColor.whiteColor()
                    self.textViewDescription.textColor = UIColor.whiteColor()
                    self.textFieldParticipant.textColor = UIColor.whiteColor()
                    
                    self.labelMeeting.borderStyle = UITextBorderStyle.None
                    self.labelDateMeeting.borderStyle = UITextBorderStyle.None
                    self.labelLocation.borderStyle = UITextBorderStyle.None
                    //self.textViewDescription.borderStyle = UITextBorderStyle.RoundedRect
                    self.textFieldParticipant.borderStyle = UITextBorderStyle.None

                    
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "updateMeeting")
                    self.loader?.hideLoader()
                    
                }
            })
        }
        
    }
    
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
    
    //MARK: - Date picker
    
    func resign() {
        self.labelDateMeeting.resignFirstResponder()
    }
    
    //MARK: - Ical
    
    func upDateInICalendar(title: String, date: String, description: String, location: String?, idCal: String, closure:(String) -> ()) {
        let store = EKEventStore()
        var id: String = ""
        
        store.requestAccessToEntityType(EKEntityTypeEvent) { (granted, error) in
            if !granted {
                println("Granted")
                return
            }
            var event: EKEvent? = nil
            if idCal != "" {
                event = store.eventWithIdentifier(idCal)
            }
            
            if event == nil {
                event = EKEvent(eventStore: store)
            }
            event!.title = title
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let mDate = dateFormatter.dateFromString(date)
            event!.location = location
            event!.startDate = mDate
            event!.endDate = event!.startDate.dateByAddingTimeInterval(60*60) //1 hour long meeting
            event!.calendar = store.defaultCalendarForNewEvents
            var err: NSError?
            store.saveEvent(event, span: EKSpanThisEvent, commit: true, error: &err)
            id = event!.eventIdentifier
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
        
        var rect: CGRect = CGRectMake(textFieldParticipant.frame.origin.x + (textFieldParticipant.frame.size.width/2),textFieldParticipant.frame.origin.y,0,0)
        popoverView!.presentPopoverFromRect(rect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Down, animated: true)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func dismissPopover() {
        popoverView!.dismissPopoverAnimated(true)
    }

    
}
