//
//  ContactsTableViewController.swift
//  Connect
//
//  Created by Abiel Gutierrez on 12/4/15.
//  Copyright © 2015 Abiel Gutierrez. All rights reserved.
//

import UIKit
import Parse

class ContactsTableViewController: UITableViewController {
    let user = PFUser.currentUser()
    var contactsArray: [PFObject]?{
        didSet{
            self.tableView.reloadData()
        }
    }
    var contactCount = 0
    var selectedRow: Int?
    var addContactAlertSent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Contacts"
        contactsArray = user!["contacts"] as? [PFUser]
    }
    
    override func viewDidAppear(animated: Bool) {
        if user!["contacts"] != nil{
            if contactCount != user!["contacts"].count{
                contactsArray = user!["contacts"] as! [PFUser]
                contactCount = contactsArray!.count
            }
        }
        
        if contactCount == 0 && !addContactAlertSent{
            let alert = UIAlertController.createAlert("Add contacts to see them here!")
            presentViewController(alert, animated: true, completion: nil)
            addContactAlertSent = true
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let contactInfo = contactsArray?[indexPath.row] as? PFUser{
            do {
                try contactInfo.fetchIfNeeded()
            } catch _ {
                print("There was an error")
            }
            //referenced: http://stackoverflow.com/questions/33038063/ios-9-parse-fetchifneeded-error-in-swift-2-0
            
            let cell = tableView.dequeueReusableCellWithIdentifier("contactCell")
            if let name = contactInfo["name"] as? String where name != ""{
                cell!.textLabel!.text = name
            } else {
                cell?.textLabel!.text = contactInfo["username"] as? String
            }
            return cell!
        } else {
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if contactsArray == nil {
            return 0
        } else {
            return contactsArray!.count
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        performSegueWithIdentifier("showContactDetails", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showContactDetails"{
            if let contactDetailTVC = segue.destinationViewController as? ContactDetailTableViewController{
                contactDetailTVC.user = contactsArray![selectedRow!] as? PFUser
            }
        }
    }
    
}
