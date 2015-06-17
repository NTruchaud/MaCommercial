//
//  ListContactTableViewController.swift
//  MaCommercial
//
//  Created by Sarah LAFORETS on 03/06/2015.
//  Copyright (c) 2015 Sarah LAFORETS. All rights reserved.
//

import UIKit
import MessageUI

class ListContactTableViewController: UITableViewController, SWTableViewCellDelegate, MFMailComposeViewControllerDelegate {
    
    var clients: [User]!
    var loader: Loader?
    
    func rightButtons() -> NSArray {
        var rightUtilityButtons: NSMutableArray = NSMutableArray()
        
        rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 0, green: 0, blue: 255, alpha: 1), icon: UIImage(named: "EmailWhite50"))
        rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 255, green: 0, blue: 0, alpha: 1), icon: UIImage(named: "DeleteWhite50"))
        return rightUtilityButtons
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader = Loader(view: self.view)
        loader?.showLoader()
        getAllClients()
        self.view.backgroundColor = UIColor(patternImage: kMCImageOfficeBackground)
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
        return clients.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("listContact", forIndexPath: indexPath) as! ListContactTableViewCell
        
        //Setup right buttons
        cell.delegate = self
        cell.rightUtilityButtons = self.rightButtons() as [AnyObject]
        
        // Get contact infos
        let imgContact: UIImage = UIImage(named: "User")!
        let name: String = "\(clients[indexPath.row].first_name) \(clients[indexPath.row].last_name)"
        let email: String = clients[indexPath.row].email
        let cellNumber: String = clients[indexPath.row].cell_number
        
        // Configure the cell...
        cell.imgContact.image = imgContact
        
        if clients[indexPath.row].picture != "" {
            var imageData = NSData(contentsOfURL: NSBundle.mainBundle()
                .URLForResource("loading", withExtension: "gif")!)
            cell.imgContact.image = UIImage.animatedImageWithData(imageData!)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let url = NSURL(string: self.clients[indexPath.row].picture)
                let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
                cell.imgContact.image = UIImage(data: data!)
            })
        }

        
        cell.labelCellNumber.text = cellNumber
        cell.labelEmail.text = email
        cell.labelName.text = name

        return cell
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("detailContactView", sender: self)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: initialization

    func getAllClients(){
        var userGet = User()
        clients = [User]()
        DataManager.sharedInstance.get(userGet, parameters: "\(userGet.Key[kMCWsType]!)=\(TypeUser.CLIENT.stringValue)", completionClosure: { (json) -> () in
            if let data = json {
                for (key, user) in data{
                    var client = User()
                    client.fromJSON(user)
                    self.clients.append(client)
                }
                for var i = 0; i < 5; i++ {
                    var client = User(id: nil, last_name: "last \(i)", first_name: "first  \(i)", email: "", password: "", cell_number: "", company: "", job: "", picture: "", postal_address: "", home_number: "", birth_date: "", type: TypeUser.CLIENT)
                    self.clients.append(client)
                }
                UtilitiesTable.animateTable(tableView: self.tableView)
                self.loader?.hideLoader()
            }
        })
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if (segue.identifier == "detailContactView") {
            var svc = segue.destinationViewController as! ClientDetailViewController
            let indexPath = tableView.indexPathForSelectedRow();
            svc.client = clients[indexPath!.row]
            svc.isNewClient = false
            svc.completionHandler = { () -> () in
                self.getAllClients()
            }
        }else if segue.identifier == "newContactView" {
            var svc = segue.destinationViewController as! ClientDetailViewController
            svc.client = nil
            svc.isNewClient = true
            svc.completionHandler = { () -> () in
                self.getAllClients()
            }
        }
    }

    
    // MARK: - SWTableViewCell
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        switch (index) {
            case 0:
                // Email button was pressed
                let mailComposeViewController = configuredMailComposeViewController(cell, index: index)
                if MFMailComposeViewController.canSendMail() {
                    self.presentViewController(mailComposeViewController, animated: true, completion: nil)
                } else {
                    self.showSendMailErrorAlert()
                }
                break;
            case 1:
                // Delete button was pressed                
                var index = self.tableView.indexPathForCell(cell)
                deleteCLient(index!)
                
                break;
            default:
            break;
        }
    }
    
    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
        return true
    }
    
    func configuredMailComposeViewController(cell: SWTableViewCell, index: Int) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        
        /*
        * Test
        */
        
        var client = clients[index]
        var clientMail = client.email
        
        /*
        * Fin Test
        */
        
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        //mailComposerVC.setToRecipients(["nurdin@gmail.com"])
        mailComposerVC.setToRecipients([clientMail])
        mailComposerVC.setSubject("Sending you an in-app e-mail...")
        mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
        
        // Set l'url de la pièce jointe
        let url = NSURL(string: "https://github.com/xeNz-/MaCommercial/blob/develop/ressources/tarif.png")
        let data = NSData(contentsOfURL: url!)
        mailComposerVC.addAttachmentData(data, mimeType: "png", fileName: "tarif.png")
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: NSLocalizedString("dialog_send_email_error_title", comment:""), message: NSLocalizedString("dialog_send_email_error_message", comment:""), delegate: self, cancelButtonTitle: NSLocalizedString("global_ok", comment:""))
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func deleteCLient(indexPath: NSIndexPath) {
        loader?.showLoader()
        var client = clients[indexPath.row]
        print(client.id)
        DataManager.sharedInstance.delete(client, completionClosure: { (json) -> () in
            self.clients.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.reloadData();
            self.loader?.hideLoader()
        })
    }
    
    @IBAction func addClient(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("newContactView", sender: self)
    }
}
