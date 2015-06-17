//
//  ReportDetailViewController.swift
//  MaCommercial
//
//  Created by iem on 09/06/2015.
//  Copyright (c) 2015 Sarah LAFORETS. All rights reserved.
//

import UIKit

class ReportDetailViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var label: UITextField!
    @IBOutlet weak var subject: UITextField!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var summary: UITextView!
    @IBOutlet weak var feedback: UITextView!
    @IBOutlet weak var signature: UITextField!
    
    @IBOutlet weak var optionButton: UIBarButtonItem!
    @IBOutlet weak var bar: UINavigationItem!
    
    var report:Report?
    var meeting:Meeting!
    var editionDefautlMode: Bool! = false
    var loader: Loader!
    var alertDatePicker : PopDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: kMCImageOfficeBackground)
        
        
        loader = Loader(view: self.view)
        
        loader.showLoader()
        DataManager.sharedInstance.get(meeting, parameters: nil) { (json) -> () in
            self.loader.hideLoader()
        }
        
        fillWithReport(report)
        if report == nil {
            setEditableModeTo(true)
        } else {
            setEditableModeTo(editionDefautlMode)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fillWithReport(report: Report?) {
        if let reportFull = report {
            label.text = reportFull.label
            subject.text = reportFull.subject
            date.text = reportFull.date
            summary.text = reportFull.summary
            feedback.text = reportFull.feedback
            signature.text = reportFull.signature
        } else {
            label.text = ""
            subject.text = ""
            subject.text = ""
            summary.text = ""
            feedback.text = ""
            signature.text = ""
        }
    }
    
    func setEditableModeTo(editableMode: Bool) {
        label.enabled = editableMode
        subject.enabled = editableMode
        date.enabled = editableMode
        summary.editable = editableMode
        feedback.editable = editableMode
        signature.enabled = editableMode
        
        if editableMode == true {
            if let reportFull = report {
                bar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: Selector("clickOnSaveModify"))
            } else {
                bar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: Selector("clickOnAdd"))
            }
            
            var color:UIColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
            
            // Font color
            label.textColor = UIColor.blackColor()
            subject.textColor = UIColor.blackColor()
            summary.textColor = UIColor.blackColor()
            feedback.textColor = UIColor.blackColor()
            signature.textColor = UIColor.blackColor()
            
            label.borderStyle = UITextBorderStyle.RoundedRect
            subject.borderStyle = UITextBorderStyle.RoundedRect
            date.borderStyle = UITextBorderStyle.RoundedRect
            summary.layer.borderColor = color.CGColor
            summary.layer.borderWidth = 1.0
            summary.layer.cornerRadius = 5.0
            feedback.layer.borderColor = color.CGColor
            feedback.layer.borderWidth = 1.0
            feedback.layer.cornerRadius = 5.0
            signature.borderStyle = UITextBorderStyle.RoundedRect
            
            alertDatePicker = PopDatePicker(forTextField: date)
            date.delegate = self

        } else {
            
            // Font color
            label.textColor = UIColor.whiteColor()
            subject.textColor = UIColor.whiteColor()
            summary.textColor = UIColor.whiteColor()
            feedback.textColor = UIColor.whiteColor()
            signature.textColor = UIColor.whiteColor()
            
            if let reportFull = report {
                bar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: Selector("clickOnModifyReport"))
            } else {
                bar.rightBarButtonItem = nil
            }
            
            var color:UIColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.0)
            label.borderStyle = UITextBorderStyle.None
            subject.borderStyle = UITextBorderStyle.None
            date.borderStyle = UITextBorderStyle.None
            summary.layer.borderColor = color.CGColor
            feedback.layer.borderColor = color.CGColor
            signature.borderStyle = UITextBorderStyle.None
        }
    }
    
    func buildReportWithId(id: Int?, AndMeeting meeting: Meeting!) -> Report {
        return Report(id: id, idMeeting:meeting.id!, label: label.text, date: date.text, subject: subject.text, summary: summary.text, feedback: feedback.text, signature: signature.text)
    }
    
    func clickOnAdd() {
        var reportFull: Report! = buildReportWithId(report?.id, AndMeeting: meeting)
        
        DataManager.sharedInstance.post(reportFull, completionClosure: { (json) -> () in
            if json == nil {
                var alert = UIAlertController(title: NSLocalizedString("global_error", comment:""), message: NSLocalizedString("report_detail_alert_upload_fail_message", comment:""), preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("global_ok", comment:""), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                self.navigationController?.popViewControllerAnimated(true)
            }
        })
    }
    
    func clickOnSaveModify() {
        var reportFull: Report! = buildReportWithId(report?.id, AndMeeting: meeting)
        
        DataManager.sharedInstance.put(reportFull, completionClosure: { (json) -> () in
            if json == nil {
                var alert = UIAlertController(title: NSLocalizedString("global_error", comment:""), message: NSLocalizedString("report_detail_alert_update_fail_message", comment:""), preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("global_ok", comment:""), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                self.setEditableModeTo(false)
            }
        })
    }
    
    func clickOnModifyReport() {
        setEditableModeTo(true)
    }
    
    // MARK: Date Picker
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if (textField === date) {
            resign()
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            formatter.timeStyle = .NoStyle
            var initDate: NSDate?
            if date.text != ""{
                initDate = formatter.dateFromString(date.text)
            }else{
                initDate = NSDate()
            }
            let dataChangedCallback : PopDatePicker.PopDatePickerCallback = { (newDate : NSDate, forTextField : UITextField) -> () in
                // here we don't use self (no retain cycle)
                forTextField.text = (newDate.ToDateMediumString() ?? "?") as String
            }
            alertDatePicker!.pick(self, initDate: initDate, dataChanged: dataChangedCallback)
            return false
        }
        else {
            return true
        }
    }
    
    func resign() {
        date.resignFirstResponder()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
