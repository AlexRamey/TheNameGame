//
//  UploadResultViewController.swift
//  TheNameGame
//
//  Created by Alex Ramey on 2/24/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

import UIKit

class UploadResultViewController: UIViewController {

    // MARK - IBOutlets
    @IBOutlet weak var photoView:UIImageView!
    @IBOutlet weak var resultLabel:UILabel!
    
    var photo:UIImage? = nil
    var resultText:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // these data properties were already set by the game view controller
        // we need this code to run on the main thread b/c it affects the UI
        // we need to explicity dispatch it to the main thread because otherwise
        // this code would run on a background thread via a completion block
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.photoView.clipsToBounds = true
            self.photoView.contentMode = UIViewContentMode.ScaleAspectFill
            self.resultLabel.text = self.resultText
            self.photoView.image = self.photo
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK - IBActions
    @IBAction func dismissResults(sender: AnyObject){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
