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
        
        self.loadNextPerson()
        self.configureViewForState()
        
        // DRIVER CODE - getPeople()
        HttpServiceClient().getPeople { (error, people) -> Void in
            if (error == nil){
                print(people)
            }else{
                print(error)
            }
        }
        // END DRIVER
        
        // DRIVER CODE - getImage()
        HttpServiceClient().getImage(15) { (error, encodedImage) -> Void in
            if (error == nil){
                print(encodedImage!)
                if (encodedImage != nil){
                    print("ok")
                    // NOT WORKING RIGHT HERE
                    if let data = NSData(base64EncodedString:encodedImage!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters){
                        print("test")
                        self.imageView.image = UIImage(data: data)
                    }
                }
            }else{
                print(error)
            }
        }
        // END DRIVER
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadNextPerson(){
        // Hard-coded for now
        self.choices = ["Michaelangelo","Leonardo","Raphael","Donatello"]
        self.personImage = UIImage(imageLiteral: "donnie")
        self.correctChoice = 3
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
        self.loadNextPerson()
        self.viewControllerState = .QuestionMode
        self.configureViewForState()
    }
    
    // Player swipes down
    @IBAction func nextPerson(sender: AnyObject){
        self.loadNextPerson()
        self.viewControllerState = .QuestionMode
        self.configureViewForState()
    }

}

