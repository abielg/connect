//
//  ContactDetailTableViewController.swift
//  Connect
//
//  Created by Abiel Gutierrez on 12/5/15.
//  Copyright © 2015 Abiel Gutierrez. All rights reserved.
//

import UIKit
import Parse
import Contacts

class ContactDetailTableViewController: UITableViewController {
    var user: PFUser?
    var contactStore = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUserData()
    }
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var phoneCell: UITableViewCell!
    @IBOutlet weak var emailCell: UITableViewCell!
    
    
    @IBOutlet weak var facebookCell: UITableViewCell!
    @IBOutlet weak var twitterCell: UITableViewCell!
    @IBOutlet weak var snapchatCell: UITableViewCell!
    
    @IBOutlet weak var addressCell: UITableViewCell!
    
    func setUpUserData(){
        if let pic = user!["profilePicture"]{
            pic.getDataInBackgroundWithBlock{ (result: NSData?, error:NSError?)-> Void in
                if let data = result{
                    self.profilePicture.image = UIImage(data: data)
                }
            }
        }
        
        if let name = user!["name"] as? String where name != ""{
            nameLabel.text = name
            usernameLabel.text = user!["username"] as? String
        } else {
            nameLabel.text = user!["username"] as? String
            usernameLabel.hidden = true
        }
        
        for account in [("facebook", facebookCell), ("twitter", twitterCell), ("mail", emailCell),
            ("phone", phoneCell), ("address", addressCell), ("snapchat", snapchatCell)]{
            let (accountString, cell) = account
            fillInCellInfo(cell, accountString: accountString)
        }
    }
    
    func fillInCellInfo(cell: UITableViewCell, accountString: String){
        if let account = user![accountString] as? String {
            cell.textLabel!.text = account
            cell.accessoryType = .DisclosureIndicator
        } else {
            cell.textLabel!.text = "N/A"
            cell.selectionStyle = .None
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cellText = tableView.cellForRowAtIndexPath(indexPath)?.textLabel!.text{
            if cellText != "N/A" {
                switch(indexPath.section, indexPath.row){
                case (1,0):
                    phoneNumberSelected(cellText)
                default:
                    break
                }
            }
        }
    }
    
    func phoneNumberSelected(phoneNumber: String){
        let alert = UIAlertController(title: "\(nameLabel.text!)'s number", message: phoneNumber, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Call", style: .Default){
            (action: UIAlertAction) -> Void in
            let phoneURL = NSURL(string:"tel://\(phoneNumber)")
            UIApplication.sharedApplication().openURL(phoneURL!)
            //referenced: http://stackoverflow.com/questions/25117321/iphone-call-from-app-in-swift-xcode-6
        })
        alert.addAction(UIAlertAction(title: "Add to Contacts", style: .Default){
            (action: UIAlertAction) -> Void in
                self.saveContact()
            }
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel,handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveContact(){
        let status = CNContactStore.authorizationStatusForEntityType(.Contacts)
        if status != CNAuthorizationStatus.Authorized {
            contactStore.requestAccessForEntityType(.Contacts){
                (access, error) -> Void in
                if access {
                    self.createContact()
                } else {
                    let error = UIAlertController.createAlert("Error", withMessage: (error?.description)!)
                    self.presentViewController(error, animated: true, completion: nil)
                }
            }
        } else {
            self.createContact()
        }
    }
    
    func createContact() {
        let contact = CNMutableContact()
        contact.contactType = CNContactType.Person
        //name
        contact.givenName = (user!["name"] as? String)!
        //phone
        let number = CNPhoneNumber(stringValue: user!["phone"] as! String)
        let phoneCNLV = CNLabeledValue(label: CNLabelPhoneNumberMobile, value: number)
        contact.phoneNumbers = [phoneCNLV]
        //picture
        let data = UIImagePNGRepresentation(profilePicture.image!)
        contact.imageData = NSData(data: data!)
        //email
        if user!["email"] != nil {
            let email = CNLabeledValue(label: CNLabelHome, value: user!["email"] as! String)
            contact.emailAddresses = [email]
        }
        
        do {
            let saveRequest = CNSaveRequest()
            saveRequest.addContact(contact, toContainerWithIdentifier: nil)
            try contactStore.executeSaveRequest(saveRequest)
            let alert = UIAlertController.createAlert("Success!", withMessage: "Contact saved.")
            self.presentViewController(alert, animated: true, completion: nil)
        } catch {
            let error = UIAlertController.createAlert("Unable to save contact.")
            self.presentViewController(error, animated: true, completion: nil)
        }
    }
}
