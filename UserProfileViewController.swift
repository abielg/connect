//
//  UserProfileViewController.swift
//  Connect
//
//  Created by Abiel Gutierrez on 12/1/15.
//  Copyright © 2015 Abiel Gutierrez. All rights reserved.
//

import UIKit
import Parse
import MobileCoreServices

class UserProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user: PFUser?
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var twitterView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var mailView: UIView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var snapchatView: UIView!
    
    @IBAction func enterAccount(sender: AnyObject) {
        var textfield = UITextField()
        var image = UIImageView()
        
        if let button = sender as? UIButton{
            if let superView = button.superview {
                for subview in superView.subviews{
                    if let field = subview as? UITextField{
                        textfield = field
                    } else if let img = subview as? UIImageView{
                        image = img
                    }
                }
                UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseIn,
                    animations: { image.alpha = 0.0 },
                    completion:{ if $0 { textfield.hidden = false } })
            }
            button.removeFromSuperview()
        }
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = user!["username"] as? String
        if user!["name"] == nil {
            changeDisplayName()
        } else if let name = self.user!["name"] as? String {
            self.nameLabel.text = name
        }
        
        if let pic = user!["profilePicture"]{
            pic.getDataInBackgroundWithBlock{ (result: NSData?, error:NSError?)-> Void in
                if let data = result{
                    self.profilePic.image = UIImage(data: data)
                }
            }
        }
        
        configureTextFields()
    }
    
    
    @IBAction func changeNameAction(sender: AnyObject) {
        changeDisplayName()
    }
    
    func changeDisplayName(){
        let alert = UIAlertController(
            title: "What's your name?",
            message: "How do you want to appear to your contacts?",
            preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Name"
        }
        alert.addAction(UIAlertAction(title: "Ok",style: .Default) {
            (action: UIAlertAction) -> Void in
            if let tf = alert.textFields?.first{
                self.user!["name"] = tf.text
                self.nameLabel.text = tf.text
                self.saveUserToParse()
            }
            })

        presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveUserToParse(){
        user!.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (!success) {
                print(error?.description)
            } else {
                //Congrats dude its saved
            }
        }
    }
    
    @IBAction func enterAddress(sender: AnyObject) {
        let alert = UIAlertController(title: "Home Address", message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
    }
    
    @IBAction func changePicture(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        let alert = UIAlertController(title: "Change Profile Picture", message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Take Picture", style: .Default) {
            (action: UIAlertAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.Camera){
                picker.sourceType = .Camera
                picker.allowsEditing = true
                if let types = UIImagePickerController.availableMediaTypesForSourceType(.Camera){
                    if types.contains(kUTTypeImage as String){
                        picker.mediaTypes = [kUTTypeImage as String]
                        self.presentViewController(picker, animated: true, completion: nil)
                    }
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Choose From Library", style: .Default){
            (action: UIAlertAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum){
                picker.sourceType = .SavedPhotosAlbum
                if let types = UIImagePickerController.availableMediaTypesForSourceType(.SavedPhotosAlbum){
                    if types.contains(kUTTypeImage as String){
                        picker.mediaTypes = [kUTTypeImage as String]
                        self.presentViewController(picker, animated: true, completion: nil)
                    }
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        profilePic.image = (info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]) as? UIImage
        if let image = profilePic.image{
            let imageData = UIImagePNGRepresentation(image)
            let imageFile = PFFile(data: imageData!)
            user!["profilePicture"] = imageFile
            saveUserToParse()
        }

        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(uiipc: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func configureTextFields() {
        for view in [facebookView, twitterView, phoneView, mailView, snapchatView]{
            for subview in view.subviews{
                if let field = subview as? UITextField{
                    field.delegate = self
                    switch(view){
                    case facebookView:
                        if user!["facebook"] != nil {
                            field.text = user!["facebook"] as? String
                        }
                    case twitterView:
                        if user!["twitter"] != nil {
                            field.text = user!["twitter"] as? String
                        }
                    case phoneView:
                        if user!["phone"] != nil {
                            field.text = user!["phone"] as? String
                        }
                    case mailView:
                        if user!["mail"] != nil {
                            field.text = user!["mail"] as? String
                        }
                    case snapchatView:
                        if user!["snapchat"] != nil {
                            field.text = user!["snapchat"] as? String
                        }
                    default: break
                    }
                    field.hidden = true
                }
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text != "" {
            if let superView = textField.superview{
                switch(superView){
                case facebookView:
                    user!["facebook"] = textField.text
                case twitterView:
                    user!["twitter"] = textField.text
                case phoneView:
                    user!["phone"] = textField.text
                case mailView:
                    user!["mail"] = textField.text
                case snapchatView:
                    user!["snapchat"] = textField.text
                default: break
                }
                saveUserToParse()
            }
        }
        return true
    }
}
