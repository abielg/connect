//
//  SearchTableViewController.swift
//  Connect
//
//  Created by Abiel Gutierrez on 12/4/15.
//  Copyright © 2015 Abiel Gutierrez. All rights reserved.
//

import UIKit
import Parse

class SearchTableViewController: UITableViewController {
    
    var userArray = [PFObject]()
    let user = PFUser.currentUser()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.navigationItem.title = "Search"
        
        //Query all other users and store them in an array
        //referenced: http://stackoverflow.com/questions/26168815/parse-com-querying-user-class-swift
        let query = PFUser.query()
        let currentUsername = user!["username"] as! String
        query!.whereKey("username", notEqualTo: currentUsername)
        query!.findObjectsInBackgroundWithBlock{
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (error != nil){
                print(error)
            } else if let array = objects{
                for object in array{
                    if let user = object as? PFUser{
                        self.userArray.append(user)
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let userInfo = userArray[indexPath.row]

        let cell = tableView.dequeueReusableCellWithIdentifier("searchCell") as! SearchTableCell
        cell.nameLabel.text = userInfo["name"] as? String

        //Set picture, if available
        if let pic = userInfo["profilePicture"]{
            pic.getDataInBackgroundWithBlock{ (result: NSData?, error:NSError?)-> Void in
                if let data = result{
                    cell.profilePic.image = UIImage(data: data)
                }
            }
        }
        
        //Set icons of what data this user has in his/her account
        var iconArray: [UIImageView] = [cell.icon1, cell.icon2, cell.icon3, cell.icon4, cell.icon5, cell.icon6]
        let accountData = ["facebook", "twitter", "phone", "mail", "address", "snapchat"]
        for account in accountData{
            if userInfo[account] != nil {
                let image = UIImage(named: "\(account)_icon_small.png")
                iconArray.first!.image = image
                iconArray.removeFirst()
            }
        }
        cell.contactUsername = userInfo["username"] as! String
        
        
        if let contactsArray = user!.objectForKey("contacts") where contactsArray.containsObject(userInfo){
            cell.connectButton.hidden = true
        } else {
            cell.connectedLabel.hidden = true
        }
        
        cell.connectButton.addTarget(self, action: "newConnectionAlert", forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    func newConnectionAlert(){
        let alert = UIAlertController(title: "New connection made!", message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok",style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
