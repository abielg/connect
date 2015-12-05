//
//  SearchTableCell.swift
//  Connect
//
//  Created by Abiel Gutierrez on 12/4/15.
//  Copyright © 2015 Abiel Gutierrez. All rights reserved.
//

import UIKit
import Parse

class SearchTableCell: UITableViewCell {
    
    let user = PFUser.currentUser()
    var contactUsername = String()
    @IBOutlet weak var icon1: UIImageView!
    @IBOutlet weak var icon2: UIImageView!
    @IBOutlet weak var icon3: UIImageView!
    @IBOutlet weak var icon4: UIImageView!
    @IBOutlet weak var icon5: UIImageView!
    @IBOutlet weak var icon6: UIImageView!
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var connectedLabel: UILabel!

    
    @IBAction func connect(sender: AnyObject) {
        let query = PFUser.query()
        query?.whereKey("username", equalTo: contactUsername)
        query?.findObjectsInBackgroundWithBlock(){
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (error != nil) {
                print(error)
            } else if let contact = objects!.first as? PFUser{
                self.user!.addObject(contact, forKey: "contacts")
                PFUser.saveUserToParse(self.user!)
                //contact.addObject(self.user!, forKey: "contacts")
                //PFUser.saveUserToParse(contact)  MIGHT IMPLEMENT LATER
            }
        }
        connectButton.hidden = true
        connectedLabel.hidden = false
    }
}
