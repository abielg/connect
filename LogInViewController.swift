//
//  LogInViewController.swift
//  Connect
//
//  Created by Abiel Gutierrez on 11/30/15.
//  Copyright © 2015 Abiel Gutierrez. All rights reserved.
//

import UIKit
import Parse

class LogInViewController: UIViewController {
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBAction func signUp(sender: AnyObject) {
        if fieldNotCompleted(){
            return
        }
        
        let user = PFUser()
        user.username = usernameTextField.text!
        user.password = passwordTextField.text!
        
        ///////CHANGE QUEUE CHANGE QUEUE CHANGE QUEUE CHANGE QUEUE CHANGE QUEUE CHANGE QUEUE CHANGE QUEUE ///////
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                if let errorString = error.userInfo["error"] as? String{
                    let alert = UIAlertController.createAlert(errorString)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                return
            } else {
                self.performSegueWithIdentifier("logInSuccessful", sender: user)
            }
        }
    }
    
    @IBAction func logIn(sender: AnyObject) {
        if fieldNotCompleted(){
            return
        }
        
        PFUser.logInWithUsernameInBackground(usernameTextField.text!, password: passwordTextField.text!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                self.performSegueWithIdentifier("logInSuccessful", sender: user)
            } else {
                if let error = error{
                    if let errorString = error.userInfo["error"] as? String{
                        let alert = UIAlertController.createAlert(errorString)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func fieldNotCompleted() -> Bool {
        if usernameTextField.text == "" {
            let alert = UIAlertController.createAlert("Please type in a username")
            presentViewController(alert, animated: true, completion: nil)
            return true
        }
        
        if passwordTextField.text == "" {
            let alert = UIAlertController.createAlert("Please type in a password")
            presentViewController(alert, animated: true, completion: nil)
            return true
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logInSuccessful" {
            if let tabController = segue.destinationViewController as? UITabBarController {
                if let nvc = tabController.viewControllers!.first as? UINavigationController{
                    if let profileVC = nvc.viewControllers.first as? UserProfileViewController{
                        if let parseUser = sender as? PFUser{
                            profileVC.user = parseUser
                        }
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

extension UIAlertController{
    class func createAlert(title: String)->UIAlertController {
        let alert = UIAlertController(title: "\(title)", message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok",style: .Cancel,handler: nil))
        return alert
    }
    
    class func createAlert(title: String, withMessage message: String)->UIAlertController {
        let alert = UIAlertController(title: "\(title)", message: "\(message)", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok",style: .Cancel,handler: nil))
        return alert
    }
}







