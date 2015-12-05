//
//  ContactDetailTableViewController.swift
//  Connect
//
//  Created by Abiel Gutierrez on 12/5/15.
//  Copyright © 2015 Abiel Gutierrez. All rights reserved.
//

import UIKit
import Parse

class ContactDetailTableViewController: UITableViewController {
    var user: PFUser?
    
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
        let alert = UIAlertController(title: "\(nameLabel.text)'s number", message: phoneNumber, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Add to Contacts", style: .Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Call", style: .Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel,handler: nil))
    }
}
