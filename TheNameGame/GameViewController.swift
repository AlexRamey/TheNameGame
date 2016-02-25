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

