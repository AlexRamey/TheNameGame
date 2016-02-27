//
//  ViewController.swift
//  TheNameGame
//
//  Created by Alex Ramey on 2/23/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    // A new enum type to help us keep track of this view controller's state
    // State 1 is questionMode, where a user still hasn't selected a choice
    // State 2 is resultMode, where a user is viewing the result of their choice
    enum GameState{
        case QuestionMode
        case ResultMode
    }
    
    // MARK: General Properties
    var viewControllerState = GameState.QuestionMode
    var numCorrectResponses:Int = 0
    var numIncorrectResponses:Int = 0
    let dataStore:DataStore = DataStore()
    var isGameOver:Bool = false
    // Question Mode Specific Properties
    var choices:[String]=[]
    var correctChoice:Int = -1
    var personImage:UIImage? = nil
    // Result Mode Specific Properties
    var userChoice:Int = -1
    // Holders for form field values during pending POST
    var formPhotoField:UIImage?
    var formNameField:String?
    
    // MARK: IBOutlet Properties
    // NavBar Reset Button
    @IBOutlet weak var resetBtn:UIBarButtonItem!
    // Labels
    @IBOutlet weak var scoreLabel:UILabel!
    @IBOutlet weak var resultLabel:UILabel!
    // Image View
    @IBOutlet weak var imageView:UIImageView!
    // Choices
    @IBOutlet weak var choiceOne: UIButton!
    @IBOutlet weak var choiceTwo: UIButton!
    @IBOutlet weak var choiceThree: UIButton!
    @IBOutlet weak var choiceFour: UIButton!
    // Swipe Gesture Recognizer
    @IBOutlet weak var swipeRecognizer:UISwipeGestureRecognizer!
    // UIActivityIndicatorView
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    
    // MARK: View Controller Code
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.imageView.clipsToBounds = true
        choiceOne.setBackgroundImage(UIImage(imageLiteral: "NeutralButton"), forState: .Normal)
        choiceTwo.setBackgroundImage(UIImage(imageLiteral: "NeutralButton"), forState: .Normal)
        choiceThree.setBackgroundImage(UIImage(imageLiteral: "NeutralButton"), forState: .Normal)
        choiceFour.setBackgroundImage(UIImage(imageLiteral: "NeutralButton"), forState: .Normal)
        
        self.resetGame(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadNextPerson(){
        /* Hard-coded for now
        self.choices = ["Michaelangelo","Leonardo","Raphael","Donatello"]
        self.personImage = UIImage(imageLiteral: "donnie")
        self.correctChoice = 3
        */
        self.activityIndicator.startAnimating()
        self.swipeRecognizer.enabled = false
        self.resetBtn.enabled = false
        self.dataStore.nextPerson { (error, name, picture) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (error != nil){
                    if (error!.code == 444){
                        self.isGameOver = true
                        let alert = UIAlertController(title: "Alert", message: "You've seen everyone!", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    else if (self.viewControllerState == .ResultMode){
                        let alert = UIAlertController(title: "Alert", message: "Failed to get next person! Try swiping right again.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    else{
                        let alert = UIAlertController(title: "Alert", message: "Failed to get next person! Try resetting again.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    self.swipeRecognizer.enabled = true
                }else{
                    self.personImage = picture
                    if (picture == nil){
                        print("nil image!")
                    }
                    let wrongTriple:(String,String,String) = self.dataStore.threeRandomNamesOtherThan(name)
                    self.choices = [wrongTriple.0, wrongTriple.1, wrongTriple.2, name]
                    self.choices.shuffleInPlace()
                    self.correctChoice = self.choices.indexOf(name)!
                    self.viewControllerState = .QuestionMode
                    self.configureViewForState()
                }
                self.resetBtn.enabled = true
                self.activityIndicator.stopAnimating()
            })
        }
        
    }
    
    func configureViewForState(){
        
        var buttons:[UIButton] = [self.choiceOne, self.choiceTwo, self.choiceThree, self.choiceFour]
        
        switch self.viewControllerState{
        case .QuestionMode:
            if ((self.numCorrectResponses + self.numIncorrectResponses) == 0){
                scoreLabel.text = "No Score Recorded Yet 👻"
            }
            self.imageView.image = self.personImage
            self.resultLabel.text = ""
            
            var index:Int
            for index = 0; index < buttons.count; ++index{
                buttons[index].setTitle(self.choices[index], forState: .Normal)
                buttons[index].setTitle(self.choices[index], forState: .Disabled)
            }
            
            self.setButtonsEnabled(true)
            self.swipeRecognizer.enabled = false
            
            
        case .ResultMode:
            if (userChoice == correctChoice){
                self.numCorrectResponses++
                self.resultLabel.text = "😁 - Swipe Right to Continue"
            }
            else{
                self.numIncorrectResponses++
                self.resultLabel.text = "😖 - Swipe Right to Continue"
            }
            let percentageCorrect:Float = ((Float)(self.numCorrectResponses) / ((Float)(self.numCorrectResponses + self.numIncorrectResponses))) * 100
            let percentageCorrectString = NSString(format: "%.1f", percentageCorrect)
            self.scoreLabel.text = "\(self.numCorrectResponses)/\(self.numCorrectResponses+self.numIncorrectResponses) (\(percentageCorrectString)%)"
            
            var index:Int
            for index = 0; index < buttons.count; ++index{
                if (index == correctChoice){
                    buttons[index].setBackgroundImage(UIImage(imageLiteral: "CorrectButton"), forState: .Disabled)
                }
                else if (index == userChoice){
                    buttons[index].setBackgroundImage(UIImage(imageLiteral: "WrongButton"), forState: .Disabled)
                }
                else{
                    buttons[index].setBackgroundImage(UIImage(imageLiteral: "DisabledButton"), forState: .Disabled)
                }
            }
            self.setButtonsEnabled(false)
            self.swipeRecognizer.enabled = true
        }
        
    }
    
    // helper function to enable/disable all buttons
    func setButtonsEnabled(isEnabled:Bool){
        self.choiceOne.enabled = isEnabled
        self.choiceTwo.enabled = isEnabled
        self.choiceThree.enabled = isEnabled
        self.choiceFour.enabled = isEnabled
    }
    
    // called by AddPersonViewController to store its form fields,
    // which this controller can then pass to the UploadResultViewController
    // when the post response comes back form the server
    func setFormFields(photo: UIImage?, name: String?){
        self.formPhotoField = photo
        self.formNameField = name
    }
    
    // display the UploadResultViewController modally to notify user of result
    func showPostResults(success:Bool){
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = storyboard.instantiateViewControllerWithIdentifier("postResultsVC") as! UploadResultViewController
        var resultText:String? = nil
        if (success){
            resultText = "Successfully added \(self.formNameField!) to the name game!☺️"
        } else{
            resultText = "Failed to add \(self.formNameField!) to the name game!😡"
        }
        
        vc.resultText = resultText
        vc.photo = self.formPhotoField
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    // Mark: IBActions
    
    // Player selects a multiple choice name option
    @IBAction func choiceSelected(sender: AnyObject){
        
        if (self.activityIndicator.isAnimating() || self.isGameOver){
            // ignore these button presses during a load or when game is already over
            return
        }
        
        let btn:UIButton = sender as! UIButton
        
        switch btn.frame.origin.y{
        case choiceOne.frame.origin.y:
            self.userChoice = 0;
        case choiceTwo.frame.origin.y:
            self.userChoice = 1;
        case choiceThree.frame.origin.y:
            self.userChoice = 2;
        default:
            self.userChoice = 3;
        }
        
        self.viewControllerState = .ResultMode
        self.configureViewForState()
    }
    
    // Player chooses to reset the game
    @IBAction func resetGame(sender: AnyObject){
        self.numCorrectResponses = 0
        self.numIncorrectResponses = 0
        self.swipeRecognizer.enabled = false
        self.isGameOver = false
        self.activityIndicator.startAnimating()
        self.resetBtn.enabled = false
        self.swipeRecognizer.enabled = false
        self.dataStore.reloadData { (error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (error != nil){
                    let alert = UIAlertController(title: "Error", message: "Failed to load data! Please try again by hitting the reset button.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                self.resetBtn.enabled = true
                self.activityIndicator.stopAnimating()
                self.loadNextPerson()
            })
        }
    }
    
    // Player swipes right
    @IBAction func nextPerson(sender: AnyObject){
        self.loadNextPerson()
    }

}

