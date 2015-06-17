//
//  PopDateViewController.swift
//  MaCommercial
//
//  Created by iem on 04/06/2015.
//  Copyright (c) 2015 iem. All rights reserved.
//

import Foundation
import UIKit

protocol DataPickerViewControllerDelegate : class {
    func datePickerVCDismissed(date : NSDate?)
}

class PopDateViewController : UIViewController {
    
    //@IBOutlet weak var container: UIView!
    @IBOutlet weak var birth_picker: UIDatePicker!
    weak var delegate : DataPickerViewControllerDelegate?
    
    var currentDate : NSDate? {
        didSet {
            updatePickerCurrentDate()
        }
    }
    
    convenience init() {
        self.init(nibName: "PopDateViewController", bundle: nil)
    }
    
    private func updatePickerCurrentDate() {
        if let _currentDate = self.currentDate {
            if let _datePicker = self.birth_picker {
                _datePicker.date = _currentDate
            }
        }
    }
    
    @IBAction func okAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) {
            let nsdate = self.birth_picker.date
            self.delegate?.datePickerVCDismissed(nsdate)
        }
    }
    
    override func viewDidLoad() {
        updatePickerCurrentDate()
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.delegate?.datePickerVCDismissed(nil)
    }
}
