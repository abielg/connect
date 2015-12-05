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
        }
        
        
    }

}
