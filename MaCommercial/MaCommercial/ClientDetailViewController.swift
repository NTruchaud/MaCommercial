//
//  ClientDetailViewController.swift
//  MaCommercial
//
//  Created by iem on 04/06/2015.
//  Copyright (c) 2015 Nils Truchaud. All rights reserved.
//

import UIKit
import MessageUI

enum TypeImage {
    case Image
    case URL
}

class ClientDetailViewController: UIViewController, MFMailComposeViewControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var client: User?
    var completionHandler: (()->())?
    var isNewClient: Bool!
    var alertDatePicker : PopDatePicker?
    var typeChangeImage : TypeImage = TypeImage.URL
    var keyOCR = [
        "FirstName",
        "LastName",
        "Email",
        "Company",
        "Job",
        "PostalAdress",
    ]

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var clientImage: UIImageView!
    @IBOutlet weak var mailButton: UIButton!
    @IBOutlet weak var jobTextField: UITextField!
    @IBOutlet weak var postalAddressTextField: UITextField!
    @IBOutlet weak var cellTextField: UITextField!
    @IBOutlet weak var officeTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var mailTextField: UITextField!
    
    @IBOutlet weak var changeClientImageButton: UIButton!
    
    @IBOutlet weak var editActionButton: UIBarButtonItem!
    
    var loader: Loader!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader = Loader(view: self.view)
        
        self.view.backgroundColor = UIColor(patternImage: kMCImageOfficeBackground)
        
        makeButtonRound(self.mailButton)
        makeImageRound(self.clientImage)
        if client != nil{
            displayClientInfos(self.client!)
            disableEdition()
        }else {
            client = User()
            enableEdition()
            setupForNewClient()
        }
        
        //Add button
        self.navigationItem.rightBarButtonItems = [self.navigationItem.rightBarButtonItem!, UIBarButtonItem(image: UIImage(named: "ocr.png"), style: UIBarButtonItemStyle.Bordered, target: self, action: "showOCR")]
        
        //Set TapRecognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "changeClientImage:")
        tapRecognizer.numberOfTapsRequired = 1
        clientImage.addGestureRecognizer(tapRecognizer)
        clientImage.userInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Sending an email
    @IBAction func sendAnEmail(sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setToRecipients([client!.email])
        mailComposerVC.setSubject("Object :")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: NSLocalizedString("dialog_send_email_error_title", comment:""), message: NSLocalizedString("dialog_send_email_error_message", comment:""), delegate: self, cancelButtonTitle: NSLocalizedString("global_ok", comment:""))
        sendMailErrorAlert.show()
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    //MARK: Design
    func makeButtonRound(button: UIButton){
        button.layer.cornerRadius = self.mailButton.frame.size.width / 2
        button.clipsToBounds = true
        button.backgroundColor = UIColor.whiteColor()
        button.layer.borderWidth = 3
        button.layer.borderColor = kMCColorPrimary.CGColor
        button.imageEdgeInsets.bottom = 10
        button.imageEdgeInsets.top = 10
        button.imageEdgeInsets.right = 10
        button.imageEdgeInsets.left = 10
    }
    
    func makeImageRound(image: UIImageView){
        image.layer.cornerRadius = self.clientImage.frame.size.width / 2
        image.clipsToBounds = true
    }
    
    func displayClientInfos(client: User){
        if client.picture != "" {
            var imageData = NSData(contentsOfURL: NSBundle.mainBundle()
                .URLForResource("loading", withExtension: "gif")!)
            self.clientImage.image = UIImage.animatedImageWithData(imageData!)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let url = NSURL(string: client.picture)
                let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
                self.clientImage.image = UIImage(data: data!)
            })
        }
        nameTextField.text = "\(client.first_name) \(client.last_name)"
        companyTextField.text = client.company
        jobTextField.text = client.job
        postalAddressTextField.text = client.postal_address
        cellTextField.text = client.cell_number
        officeTextField.text = client.home_number
        birthdayTextField.text = client.birth_date
        mailTextField.text = client.email
    }
    
    //MARK: Edition
    
    @IBAction func editClient(sender: UIBarButtonItem) {
        if sender.title == NSLocalizedString("button_edit", comment:""){
            enableEdition()
        }else{
            saveClient()
        }
    }
    

    func disableEdition(){
        editActionButton.title = NSLocalizedString("button_edit", comment:"")
        nameTextField.hidden = false
        nameTextField.enabled = false
        nameTextField.borderStyle = UITextBorderStyle.None
        nameTextField.backgroundColor = UIColor.clearColor()
        nameTextField.textColor = UIColor.whiteColor()
        firstNameTextField.hidden = true
        lastNameTextField.hidden = true
        
        companyTextField.enabled = false
        companyTextField.borderStyle = UITextBorderStyle.None
        companyTextField.backgroundColor = UIColor.clearColor()
        companyTextField.textColor = UIColor.whiteColor()
        
        jobTextField.enabled = false
        jobTextField.borderStyle = UITextBorderStyle.None
        jobTextField.textColor = UIColor.whiteColor()
        postalAddressTextField.enabled = false
        postalAddressTextField.borderStyle = UITextBorderStyle.None
        postalAddressTextField.textColor = UIColor.whiteColor()
        cellTextField.enabled = false
        cellTextField.borderStyle = UITextBorderStyle.None
        cellTextField.textColor = UIColor.whiteColor()
        officeTextField.enabled = false
        officeTextField.borderStyle = UITextBorderStyle.None
        officeTextField.textColor = UIColor.whiteColor()
        birthdayTextField.enabled = false
        birthdayTextField.borderStyle = UITextBorderStyle.None
         birthdayTextField.textColor = UIColor.whiteColor()
        mailTextField.enabled = false
        mailTextField.borderStyle = UITextBorderStyle.None
        mailTextField.textColor = UIColor.whiteColor()
        
        changeClientImageButton.hidden = true
        makeButtonRound(changeClientImageButton)
        mailButton.enabled = true
    }
    
    func enableEdition(){
        editActionButton.title = NSLocalizedString("button_save", comment:"")
        nameTextField.hidden = true
        firstNameTextField.hidden = false
        firstNameTextField.text = client?.first_name
        firstNameTextField.textColor = UIColor.blackColor()
        lastNameTextField.hidden = false
        lastNameTextField.text = client?.last_name
        lastNameTextField.textColor = UIColor.blackColor()
        
        nameTextField.backgroundColor = UIColor.whiteColor()
        nameTextField.textColor = UIColor.blackColor()
        companyTextField.enabled = true
        companyTextField.borderStyle = UITextBorderStyle.RoundedRect
        companyTextField.backgroundColor = UIColor.whiteColor()
        companyTextField.textColor = UIColor.blackColor()
        
        jobTextField.enabled = true
        jobTextField.borderStyle = UITextBorderStyle.RoundedRect
        jobTextField.textColor = UIColor.blackColor()
        postalAddressTextField.enabled = true
        postalAddressTextField.borderStyle = UITextBorderStyle.RoundedRect
        postalAddressTextField.textColor = UIColor.blackColor()
        cellTextField.enabled = true
        cellTextField.borderStyle = UITextBorderStyle.RoundedRect
        cellTextField.textColor = UIColor.blackColor()
        officeTextField.enabled = true
        officeTextField.borderStyle = UITextBorderStyle.RoundedRect
        officeTextField.textColor = UIColor.blackColor()
        birthdayTextField.enabled = true
        birthdayTextField.borderStyle = UITextBorderStyle.RoundedRect
        birthdayTextField.textColor = UIColor.blackColor()
        mailTextField.enabled = true
        mailTextField.borderStyle = UITextBorderStyle.RoundedRect
        mailTextField.textColor = UIColor.blackColor()
        
        
        mailButton.enabled = false
        
        changeClientImageButton.hidden = false
        makeButtonRound(changeClientImageButton)
        alertDatePicker = PopDatePicker(forTextField: birthdayTextField)
        birthdayTextField.delegate = self
    }
    
    func saveClient(){
        client!.company = companyTextField.text
        client!.job = jobTextField.text
        client!.postal_address = postalAddressTextField.text
        client!.cell_number = cellTextField.text
        client!.home_number = officeTextField.text
        client!.birth_date = birthdayTextField.text
        client!.email = mailTextField.text
        
        client!.first_name = firstNameTextField.text
        client!.last_name = lastNameTextField.text
        client!.type = .CLIENT
        
        //Enable loader + Disable Save button
        loader!.showLoader()
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        if typeChangeImage == TypeImage.Image {
            let data : NSMutableData = NSMutableData(data: UIImageJPEGRepresentation(self.clientImage.image, 70))
            let urlRequest = urlRequestWithComponents(kMCPathUpload, parameters: nil, imageData: data)
            
            upload(urlRequest.0, urlRequest.1)
                .responseJSON { (request, response, JSON, error) in
                    if response != nil {
                        if response!.statusCode == 200 {
                            self.client!.picture = urlRequest.2
                            self.executeClient()
                        }
                    }
                    else {
                        self.loader!.hideLoader()
                        self.navigationItem.rightBarButtonItem?.enabled = true
                        println("Error on upload file")
                    }
            }
        }
        else {
            self.executeClient()
        }
    }
    
    func executeClient() {
        if isNewClient == false {
            DataManager.sharedInstance.put(client!, completionClosure: { (json) -> () in
                self.disableEdition()
                self.loader!.hideLoader()
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.completionHandler!()
            })
        }else{
            DataManager.sharedInstance.post(client!, completionClosure: { (json) -> () in
           self.loader!.hideLoader()
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.navigationController?.popViewControllerAnimated(true)
                self.completionHandler!()
            })
        }
    }

    @IBAction func changeClientImage(sender: UIButton) {
        if editActionButton.title != NSLocalizedString("button_edit", comment:"") {
            //Create Sheet
            let actionSheet = UIActionSheet(title: NSLocalizedString("client_detail_image_dialog_title", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("global_cancel", comment: ""), destructiveButtonTitle: nil)
            actionSheet.addButtonWithTitle(NSLocalizedString("client_detail_image_dialog_action_camera", comment: ""))
            actionSheet.addButtonWithTitle(NSLocalizedString("client_detail_image_dialog_action_library", comment: ""))
            actionSheet.addButtonWithTitle(NSLocalizedString("client_detail_image_dialog_action_url", comment: ""))
        
            //Show Sheet
            actionSheet.showInView(self.view)
        }
    }
    
    func setupForNewClient(){
        editActionButton.title = NSLocalizedString("button_save", comment:"")
        firstNameTextField.placeholder = NSLocalizedString("client_detail_first_name", comment:"")
        firstNameTextField.text = ""
        lastNameTextField.placeholder = NSLocalizedString("client_detail_last_name", comment:"")
        lastNameTextField.text = ""
        companyTextField.placeholder = NSLocalizedString("client_detail_company", comment:"")
        companyTextField.text = ""
        
        jobTextField.placeholder = NSLocalizedString("client_detail_job", comment:"")
        jobTextField.text = ""
        postalAddressTextField.placeholder = NSLocalizedString("client_detail_postal_address", comment:"")
        postalAddressTextField.text = ""
        cellTextField.placeholder = NSLocalizedString("client_detail_cell", comment:"")
        cellTextField.text = ""
        officeTextField.placeholder = NSLocalizedString("client_detail_office", comment:"")
        officeTextField.text = ""
        birthdayTextField.placeholder = NSLocalizedString("client_detail_birthday", comment:"")
        birthdayTextField.text = ""
        mailTextField.placeholder = NSLocalizedString("client_detail_email", comment:"")
        mailTextField.text = ""

    }
    
    // MARK: Date Picker
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if (textField === birthdayTextField) {
            resign()
            
            let dateFormat = NSDateFormatter()
            dateFormat.dateFormat = "dd/MM/yyyy"
            
            var initDate: NSDate = NSDate()
            if birthdayTextField.text != "" {
                initDate = dateFormat.dateFromString(birthdayTextField.text)!
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
        birthdayTextField.resignFirstResponder()
    }

    func showImageController(type: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = type
        imagePicker.allowsEditing = false
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func setLinkImage() {
        var alert = UIAlertController(title: NSLocalizedString("client_detail_image_dialog_title", comment:""), message: NSLocalizedString("client_detail_image_dialog_message", comment:""), preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = NSLocalizedString("client_detail_image_dialog_place_holder", comment:"")
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("global_ok", comment:""), style: .Default, handler: { (action) -> Void in
            let urlTextField = alert.textFields![0] as! UITextField
            self.client!.picture = urlTextField.text
            self.typeChangeImage = TypeImage.URL
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("global_cancel", comment:""), style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - UIActionSheetDelegate
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        switch buttonIndex {
        case 1:
            showImageController(UIImagePickerControllerSourceType.Camera)
            break
        case 2:
            showImageController(UIImagePickerControllerSourceType.PhotoLibrary)
            break
        case 3:
            setLinkImage()
            break
        default:
            break
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.clientImage.image = image
            typeChangeImage = TypeImage.Image
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>?, imageData:NSData) -> (URLRequestConvertible, NSData, String) {
        
        // create url request to send
        var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Method.POST.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // create name
        let format = NSDateFormatter()
        format.timeStyle = .NoStyle
        format.dateStyle = .ShortStyle
        
        let nameFile = "\(client!.last_name)_\(arc4random()).jpg"
        
        // add image
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"\(nameFile)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        
        // add parameters
        if parameters != nil {
            for (key, value) in parameters!	 {
                uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
            }
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // return URLRequestConvertible and NSData
        return (ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData, kMCPathResources + "/ressources/uploads/" + nameFile)
    }

    func showOCR() {
        self.performSegueWithIdentifier("showOCR", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showOCR" {
            let destinationController = segue.destinationViewController as! OCRViewController
            destinationController.keys = keyOCR
            destinationController.completionHandler = { (data) -> () in
                for var i = 0; i < self.keyOCR.count; i++ {
                    if let valueData = data[self.keyOCR[i]] {
                        self.setDataReturnOCR(self.keyOCR[i], value: valueData)
                    }
                }
            }
        }
    }
    
    func setDataReturnOCR(key: String, value: String) {
        switch key {
        case "FirstName":
            self.firstNameTextField.text = value
            break
        case "LastName":
            self.lastNameTextField.text = value
            break
        case "Email":
            self.mailTextField.text = value
            break
        case "Company":
            self.companyTextField.text = value
            break
        case "Job":
            self.jobTextField.text = value
            break
        case "PostalAdress":
            self.postalAddressTextField.text = value
            break
        default:
            break
        }
    }
    
}
