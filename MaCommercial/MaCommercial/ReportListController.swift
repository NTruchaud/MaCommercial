//
//  reportListController.swift
//  MaCommercial
//
//  Created by iem on 09/06/2015.
//

import Foundation
import UIKit

class ReportListController: UITableViewController, SWTableViewCellDelegate {
    
    var reports: [Report]! = [Report]()
    
    func rightButtons() -> NSArray {
        var rightUtilityButtons: NSMutableArray = NSMutableArray()
        
        rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 255, green: 0, blue: 0, alpha: 1), icon: UIImage(named: "DeleteWhite50"))
        return rightUtilityButtons
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init loader 
        loader = Loader(view: self.view)
        self.view.backgroundColor = UIColor(patternImage: kMCImageOfficeBackground)
    }
    
    override func viewWillAppear(animated: Bool) {
        reports.removeAll()
        tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        loader?.showLoader()
        reports = [Report]()
        
        var user = User().fromJSON(JSON(NSUserDefaultsManager.getValue(key: kMCUserKey)!))
        Participant.getMeetingsForUser(user, completionClosure: { (meeting) -> () in
            var entity: Report = Report()
            var params = "id_meeting=\(meeting.id!)"
            DataManager.sharedInstance.get(entity, parameters: params, completionClosure: { (json) -> () in
                loader?.hideLoader()
                if let data = json {
                    for (key, keyReport) in data{
                        var report = Report()
                        report.fromJSON(keyReport)
                        
                        self.reports.append(report)
                    }
                    UtilitiesTable.animateTable(tableView: self.tableView)
                }
            })
        })
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return reports.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("listReport", forIndexPath: indexPath) as! ListReportTableViewCell
        
        //Setup right buttons
        cell.delegate = self
        cell.rightUtilityButtons = self.rightButtons() as [AnyObject]
        
        // Get report infos
        let reportLabel: String = "\(reports[indexPath.row].label)"
        let dateLabel: String = reports[indexPath.row].date
        
        // Configure the cell...
        cell.labelReportLabel.text = reportLabel
        cell.labelReportDate.text = dateLabel
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("DetailReport", sender: self)
    }

    
    // MARK: - SWTableViewCell
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        loader?.showLoader()
        // Delete button was pressed
        var reportGet = reports[index]
        var indexPath = self.tableView.indexPathForCell(cell)
        DataManager.sharedInstance.delete(reportGet, completionClosure: { (json) -> () in
            self.reports.removeAtIndex(indexPath!.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.reloadData();
            loader?.hideLoader()
        })
    }
    
    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailReport" {
            var rlc = segue.destinationViewController as! ReportDetailViewController
            rlc.report = reports[tableView.indexPathForSelectedRow()!.row]
            rlc.meeting = Meeting(id: reports[tableView.indexPathForSelectedRow()!.row].idMeeting, date: "", label: "", description: "", location: "", idIcal: nil)
        }
        
    }
}
