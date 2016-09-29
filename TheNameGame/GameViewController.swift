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
        case questionMode
        case resultMode
    }
    
    // MARK: General Properties
    var viewControllerState = GameState.questionMode
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
        self.imageView.contentMode = UIViewContentMode.scaleAspectFill
        self.imageView.clipsToBounds = true
        choiceOne.setBackgroundImage(UIImage(imageLiteralResourceName: "NeutralButton"), for: UIControlState())
        choiceTwo.setBackgroundImage(UIImage(imageLiteralResourceName: "NeutralButton"), for: UIControlState())
        choiceThree.setBackgroundImage(UIImage(imageLiteralResourceName: "NeutralButton"), for: UIControlState())
        choiceFour.setBackgroundImage(UIImage(imageLiteralResourceName: "NeutralButton"), for: UIControlState())
        scoreLabel.text = "No Score Recorded Yet 👻"
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
        self.swipeRecognizer.isEnabled = false
        self.resetBtn.isEnabled = false
        self.dataStore.nextPerson { (error, name, picture) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if (error != nil){
                    if (error!.code == 444){
                        self.isGameOver = true
                        let alert = UIAlertController(title: "Alert", message: "You've seen everyone!", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else if (self.viewControllerState == .resultMode){
                        let alert = UIAlertController(title: "Alert", message: "Failed to get next person! Try swiping right again.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else{
                        let alert = UIAlertController(title: "Alert", message: "Failed to get next person! Try resetting again.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    self.swipeRecognizer.isEnabled = true
                }else{
                    self.personImage = picture
                    if (picture == nil){
                        print("nil image!")
                    }
                    let wrongTriple:(String,String,String) = self.dataStore.threeRandomNamesOtherThan(name)
                    self.choices = [wrongTriple.0, wrongTriple.1, wrongTriple.2, name]
                    self.choices.shuffleInPlace()
                    self.correctChoice = self.choices.index(of: name)!
                    self.viewControllerState = .questionMode
                    self.configureViewForState()
                }
                self.resetBtn.isEnabled = true
                self.activityIndicator.stopAnimating()
            })
        }
        
    }
    
    func configureViewForState(){
        
        var buttons:[UIButton] = [self.choiceOne, self.choiceTwo, self.choiceThree, self.choiceFour]
        
        switch self.viewControllerState{
        case .questionMode:
            if ((self.numCorrectResponses + self.numIncorrectResponses) == 0){
                scoreLabel.text = "No Score Recorded Yet 👻"
            }
            self.imageView.image = self.personImage
            self.resultLabel.text = ""
            
            for index in 0..<buttons.count{
                buttons[index].setTitle(self.choices[index], for: UIControlState())
                buttons[index].setTitle(self.choices[index], for: .disabled)
            }
            
            self.setButtonsEnabled(true)
            self.swipeRecognizer.isEnabled = false
            
            
        case .resultMode:
            if (userChoice == correctChoice){
                self.numCorrectResponses += 1
                self.resultLabel.text = "😁 - Swipe Right to Continue"
            }
            else{
                self.numIncorrectResponses += 1
                self.resultLabel.text = "😖 - Swipe Right to Continue"
            }
            let percentageCorrect:Float = ((Float)(self.numCorrectResponses) / ((Float)(self.numCorrectResponses + self.numIncorrectResponses))) * 100
            let percentageCorrectString = NSString(format: "%.1f", percentageCorrect)
            self.scoreLabel.text = "\(self.numCorrectResponses)/\(self.numCorrectResponses+self.numIncorrectResponses) (\(percentageCorrectString)%)"
            
            for index in 0..<buttons.count{
                if (index == correctChoice){
                    buttons[index].setBackgroundImage(UIImage(imageLiteralResourceName: "CorrectButton"), for: .disabled)
                }
                else if (index == userChoice){
                    buttons[index].setBackgroundImage(UIImage(imageLiteralResourceName: "WrongButton"), for: .disabled)
                }
                else{
                    buttons[index].setBackgroundImage(UIImage(imageLiteralResourceName: "DisabledButton"), for: .disabled)
                }
            }
            self.setButtonsEnabled(false)
            self.swipeRecognizer.isEnabled = true
        }
        
    }
    
    // helper function to enable/disable all buttons
    func setButtonsEnabled(_ isEnabled:Bool){
        self.choiceOne.isEnabled = isEnabled
        self.choiceTwo.isEnabled = isEnabled
        self.choiceThree.isEnabled = isEnabled
        self.choiceFour.isEnabled = isEnabled
    }
    
    // called by AddPersonViewController to store its form fields,
    // which this controller can then pass to the UploadResultViewController
    // when the post response comes back form the server
    func setFormFields(_ photo: UIImage?, name: String?){
        self.formPhotoField = photo
        self.formNameField = name
    }
    
    // display the UploadResultViewController modally to notify user of result
    func showPostResults(_ success:Bool){
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "postResultsVC") as! UploadResultViewController
        var resultText:String? = nil
        if (success){
            resultText = "Successfully added \(self.formNameField!) to the name game!☺️"
        } else{
            resultText = "Failed to add \(self.formNameField!) to the name game!😡"
        }
        
        vc.resultText = resultText
        vc.photo = self.formPhotoField
        
        self.present(vc, animated: true, completion: nil)
    }
    
    // Mark: IBActions
    
    // Player selects a multiple choice name option
    @IBAction func choiceSelected(_ sender: AnyObject){
        
        if (self.activityIndicator.isAnimating || self.isGameOver){
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
        
        self.viewControllerState = .resultMode
        self.configureViewForState()
    }
    
    // Player chooses to reset the game
    @IBAction func resetGame(_ sender: AnyObject){
        self.numCorrectResponses = 0
        self.numIncorrectResponses = 0
        self.swipeRecognizer.isEnabled = false
        self.isGameOver = false
        self.activityIndicator.startAnimating()
        self.resetBtn.isEnabled = false
        self.swipeRecognizer.isEnabled = false
        self.dataStore.reloadData { (error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if (error != nil){
                    let alert = UIAlertController(title: "Error", message: "Failed to load data! Please try again by hitting the reset button.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                self.resetBtn.isEnabled = true
                self.activityIndicator.stopAnimating()
                self.loadNextPerson()
            })
        }
    }
    
    // Player swipes right
    @IBAction func nextPerson(_ sender: AnyObject){
        self.loadNextPerson()
    }

}

