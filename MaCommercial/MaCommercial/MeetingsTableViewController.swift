//
//  MeetingsTableViewController.swift
//  MaCommercial
//
//  Created by iem on 04/06/2015.
//  Copyright (c) 2015 Nils Truchaud. All rights reserved.
//

import UIKit
import EventKit
import Foundation

class MeetingsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate, UITabBarDelegate {
    
    enum SortType{
        case DAY
        case MONTH
        case YEAR
    }
    
    @IBOutlet weak var tabSortType: UITabBar!
    @IBOutlet weak var tabAllMeetings: UITableView!

    var meetings : [Meeting]?
    var allDates : [[Meeting]]! = []
    
    var lastSortType : SortType! = SortType.DAY
    let indexButtonActivated : Int! = 0
    
    //MARK: - ViewLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = UIColor(patternImage: kMCImageOfficeBackground)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Add title to the view
        self.title = NSLocalizedString("meetings_list_title", comment: "")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addNewMeetingSegue")
        
		self.view.backgroundColor = UIColor(patternImage: kMCImageOfficeBackground)

        meetings = []
        getMeetingFromDB()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    func rightButtons() -> NSArray {
        var rightUtilityButtons: NSMutableArray = NSMutableArray()
        
        rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 0, green: 0, blue: 255, alpha: 1), icon: UIImage(named: "report"))
        rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 255, green: 0, blue: 0, alpha: 1), icon: UIImage(named: "DeleteWhite50"))
        return rightUtilityButtons
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        
        return allDates.count
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(patternImage: kMCImageOfficeBackground)
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section < allDates.count {
            return getDate(allDates[section][0].date, bySortType: lastSortType) as String
        }
        
        return ""
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return allDates[section].count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("meetingCell", forIndexPath: indexPath) as! SWTableViewCell
        
        //Setup right buttons
        cell.delegate = self
        cell.rightUtilityButtons = self.rightButtons() as [AnyObject]

        if let meeting : Meeting = allDates?[indexPath.section][indexPath.row] {
            cell.accessoryView?.backgroundColor = UIColor.whiteColor()
            cell.textLabel?.text = meeting.label
            cell.detailTextLabel?.text = meeting.date + " - " + meeting.location
        }

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("meetingDetail", sender: self)
    }
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        var goToReport = UITableViewRowAction(style: .Normal, title: "Report") { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            let meeting: Meeting = self.allDates![indexPath.section][indexPath.row]
            var report: Report = Report()
            var id: Int = meeting.id!
            DataManager.sharedInstance.get(report, parameters: "\(report.Key[kMCWsMeeting]!)=\(id)", completionClosure: { (json) -> () in
                println(json)
                if var data = json{
                    for (key, jsonReport) in data{
                        report = Report()
                        report.fromJSON(jsonReport)
                        break
                    }
                }
                
                let activityViewController :ReportDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ReportDetailViewController") as! ReportDetailViewController
                activityViewController.meeting = meeting
                
                activityViewController.report = (report.id == nil ? nil : report)
                self.navigationController?.pushViewController(activityViewController, animated: true)
            })
            
        }
        
        goToReport.backgroundColor = UIColor.blueColor()
        
        return [goToReport]
    }
    
    //MARK: - Custom func
    
    func sortAllDatesBy(sortType : SortType) {
        
        allDates.removeAll(keepCapacity: false)
        
        if let meetingsFill = meetings {
            for meeting in meetingsFill {
                
                var isGrouped = false
                for var index = 0; index < allDates.count; index++ {

                    var date1 = getDate(allDates[index][0].date, bySortType: sortType)
                    var date2 = getDate(meeting.date, bySortType: sortType)
                    
                    if date1 == date2 {
                        allDates[index].append(meeting)
                        isGrouped = true
                    }
                }
                if isGrouped == false {
                    allDates.append([])
                    allDates[allDates.count-1].append(meeting)
                }
                
            }
        }
        
        lastSortType = sortType
        UtilitiesTable.animateTable(tableView: self.tabAllMeetings)
    }
    
    func getDate(date : NSString, bySortType sortType : SortType) -> NSString {
        if date == "Jan 1, 2025"{
            return ""
        } else if date == "Mar 1, 1990" {
            return ""
        } else if date != "" {
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            var dateString = dateFormatter.dateFromString(date as String)
            
            var dateFormatterToString = NSDateFormatter()
            
            switch sortType {
            case SortType.DAY:
                dateFormatterToString.dateFormat = "dd/MM/yyyy"
                break
            case SortType.MONTH:
                dateFormatterToString.dateFormat = "MM/yyyy"
                break;
            case SortType.YEAR:
                dateFormatterToString.dateFormat = "yyyy"
                break;
            }
            
            return dateFormatterToString.stringFromDate(dateString!)
        }  else {
            return ""
        }
    }
    
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        let index = find(tabBar.items as! [UITabBarItem], item)
        
        if  index == 0 {
            sortAllDatesBy(SortType.DAY)
        } else if index == 1 {
            sortAllDatesBy(SortType.MONTH)
        } else if index == 2 {
            sortAllDatesBy(SortType.YEAR)
        }
    }
    
    //MARK: - DataBase
    
    func getMeetingFromDB() {
        var meetingEntity: Meeting = Meeting()
        var dates = [NSDate]()
        var user = User().fromJSON(JSON(NSUserDefaultsManager.getValue(key: kMCUserKey)!))
                    
        Participant.getMeetingsForUser(user, completionClosure: { (meeting) -> () in
            self.meetings?.append(meeting)
            self.meetings?.sort(self.sorterMeetings)
            
            self.tabSortType.selectedItem = self.tabSortType.items![self.indexButtonActivated] as? UITabBarItem
            self.sortAllDatesBy(self.lastSortType)
            
            
            UtilitiesTable.animateTable(tableView: self.tabAllMeetings)
        })
        
    }
    
    func sorterMeetings(this:Meeting, that:Meeting) -> Bool {
        let dateFormatter = NSDateFormatter()
        //dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateThis = dateFormatter.dateFromString(this.date)
        let dateThat = dateFormatter.dateFromString(that.date)
        
        if (dateThis == nil || dateThat == nil) {
            return true
        } else {
            return dateThis!.compare(dateThat!) == NSComparisonResult.OrderedDescending
        }
    }
    

    func printMeetings() {
        for (var i = 0 ; i < self.meetings!.count; i++) {
            println(self.meetings![i].date)
        }
        
    }
    
    //MARK: - NAVIGATION
    
    func addNewMeetingSegue() {
        self.performSegueWithIdentifier("addMeeting", sender: nil)
    
	}
    
    // MARK: - SWTableViewCell
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        switch (index) {
        case 0:
            let indexPath = self.tabAllMeetings.indexPathForCell(cell)!
            let meeting: Meeting = self.allDates![indexPath.section][indexPath.row]
            var report: Report = Report()
            var id: Int = meeting.id!
            
            DataManager.sharedInstance.get(report, parameters: "\(report.Key[kMCWsMeeting]!)=\(id)", completionClosure: { (json) -> () in
                println(json)
                if var data = json{
                    for (key, jsonReport) in data{
                        report = Report()
                        report.fromJSON(jsonReport)
                        break
                    }
                }
                
                let activityViewController :ReportDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ReportDetailViewController") as! ReportDetailViewController
                activityViewController.meeting = meeting
                
                activityViewController.report = (report.id == nil ? nil : report)
                self.navigationController?.pushViewController(activityViewController, animated: true)
                })
            break;
        case 1:
            let indexPath = self.tabAllMeetings.indexPathForCell(cell)!
            let selectedMeeting: Meeting = self.allDates[indexPath.section][indexPath.row]
            let idIcal = selectedMeeting.idIcal
            removeIcalEvent(idIcal!)
            self.allDates[indexPath.section].removeAtIndex(indexPath.row)
            
            self.meetings!.removeAtIndex(indexPath.row)
            
            
            if self.allDates[indexPath.section].count == 0 {
                self.allDates.removeAtIndex(indexPath.section)
            }
            
            Participant.removeParticpantsInMeeting(selectedMeeting)
            
            DataManager.sharedInstance.delete(selectedMeeting, completionClosure: { (json) -> () in
                self.tabAllMeetings.reloadSectionIndexTitles()
                self.tabAllMeetings.reloadData()
            })

                break;
        default:
            break;
        }
    }
    
    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
        return true
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "meetingDetail" {
            var svc = segue.destinationViewController as! DetailsMeetingViewController
            var indexPath: NSIndexPath = self.tabAllMeetings.indexPathForSelectedRow()!
            let selectedMeeting: Meeting = self.allDates[indexPath.section][indexPath.row]
            
            svc.meeting = selectedMeeting
        }
    }
    
    //MARK: - Error
    
    func showErrorMessage(message: String) {
        TSMessage.showNotificationInViewController(self, title: message, subtitle: "", type: TSMessageNotificationType.Error, duration: NSTimeInterval(500))
    }
    
    //MARK: - Ical
    
    func removeIcalEvent(id: String) {
        let store = EKEventStore()
        store.requestAccessToEntityType(EKEntityTypeEvent) {(granted, error) in
            if !granted { return }
            let eventToRemove = store.eventWithIdentifier(id)
            if eventToRemove != nil {
                var err: NSError?
                store.removeEvent(eventToRemove, span: EKSpanThisEvent, commit: true, error: &err)
            }
        }
    }


}
