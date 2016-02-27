//
//  AddPersonViewController.swift
//  TheNameGame
//
//  Created by Alex Ramey on 2/24/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

// UIImagePickerController Tutorial: http://www.codingexplorer.com/choosing-images-with-uiimagepickercontroller-in-swift/

import UIKit

class AddPersonViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: IBOutlet Properties
    @IBOutlet weak var photoField:UIImageView!
    @IBOutlet weak var nameField:UITextField!
    @IBOutlet weak var doneBtn:UIBarButtonItem!
    
    var keyboardHeight:CGFloat = 0
    let imagePicker = UIImagePickerController()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // register to be notified when keyboard is about to show by calling our keyboardWillShow: method
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.nameField.delegate = self
        self.nameField.returnKeyType = UIReturnKeyType.Done    // instead of "return"
        
        self.doneBtn.enabled = false                           // enabled for valid input only
        
        self.photoField.contentMode = .ScaleAspectFill         // maintain aspect ratio, fill space
        self.photoField.clipsToBounds = true
        
        // This view controller must also conform to UINavigationControllerDelegate protocol
        // to be a UIImagePickerControllerDelegate
        imagePicker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Respond to notification from notification center that keyboard is about to show
    func keyboardWillShow(notification:NSNotification) {
        print("notified")
        // if the user is editing the name field, we wish to shift the entire view up 
        // so the keyboard doesn't cover it up.
        if (self.nameField.editing){
            let userInfo:NSDictionary = notification.userInfo!
            let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
            let keyboardRectangle = keyboardFrame.CGRectValue()
            self.keyboardHeight = keyboardRectangle.height
            self.shiftViewForKeyboardHiddenState(false)
        }
        
    }
    
    // shift the view up or down depending on if keyboard is hidden
    func shiftViewForKeyboardHiddenState(isHidden:Bool){
        UIView .animateWithDuration(0.1, animations: { () -> Void in
            self.view.frame = CGRectMake(self.view.frame.origin.x, (isHidden ? 0 : -1) * self.keyboardHeight, self.view.frame.width, self.view.frame.height)
        });
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField : UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func checkValidInput() {
        // Disable save button if title field is empty or if there is no picture
        if ((self.nameField.text != nil) && !(self.nameField.text!.isEmpty)
            && (self.photoField.image != nil)){
            doneBtn.enabled = true
        }else{
            doneBtn.enabled = false
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable save button while editing title
        doneBtn.enabled = false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField == self.nameField){
            self.shiftViewForKeyboardHiddenState(true)
        }
        checkValidInput()
    }
    
    // MARK: UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.photoField.image = pickedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
        checkValidInput()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
        checkValidInput()
    }
    
    // MARK: IBActions
    // dismiss keyboard if user taps background
    @IBAction func tapRecieved(sender: AnyObject){
        print("tap received")
        self.view.endEditing(true)
    }
    
    // launch UIImagePickerController for user to select an image
    @IBAction func selectPhoto(sender:AnyObject){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // post the form to the database
    @IBAction func submitForm(sender:AnyObject){
        // Fire off the post attempt
        let client = HttpServiceClient()
        // snapshot the navController as it won't be available as a property when this completion
        // block fires since we pop this view controller from the nav stack immediately
        let navController = self.navigationController!
        client.postData(self.photoField.image!, name: self.nameField.text!) { (error) -> Void in
            if let vc = navController.viewControllers[0] as? GameViewController{
                // on completion, have the game screen present the post results screen
                vc.showPostResults(error == nil)
            }
        }
        
        // store the form fields on the game view controller so it can later pass them to the post results screen
        if let vc = navController.viewControllers[0] as? GameViewController{
            vc.setFormFields(self.photoField.image, name: self.nameField.text)
        }
        
        // and then pop this view controller
        self.navigationController!.popViewControllerAnimated(true)
    }
}