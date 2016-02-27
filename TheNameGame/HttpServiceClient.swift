//
//  HttpServiceClient.swift
//  TheNameGame
//
//  Created by Alex Ramey on 2/26/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

import UIKit

class HttpServiceClient: NSObject {

    let rdsEndPoint = "http://ec2-54-172-14-127.compute-1.amazonaws.com/service.php";
    
    override init() {
        super.init()
        // custom initialization
    }
    
    func postData(image: UIImage, name: String, completion: (error: NSError?) -> Void){
        let request = NSMutableURLRequest(URL: (NSURL(string:self.rdsEndPoint))!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        if let imageData = UIImageJPEGRepresentation(image, 0.5)
        {
            // Create your request string with parameter name as defined in PHP file
            let requestString: String = "name=\(name)&imageData=\(imageData.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn))"
            // Create Data from request
            let requestData: NSData = NSData(bytes: String(requestString.utf8), length: requestString.characters.count)
            // Set content-type
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
            request.HTTPBody = requestData
            
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                print("Response: \(response)")
                print("Error: \(error)")
                if (data != nil){
                    if let strData = NSString(data: data!, encoding: NSUTF8StringEncoding){
                        print("Body: \(strData)")
                        if (strData == "success")
                        {
                            completion(error:nil)
                        }else{
                            completion(error:NSError(domain: "HTTP POST", code: 478, userInfo: nil));
                        }
                    }else{
                        completion(error:NSError(domain: "HTTP POST", code: 479, userInfo: nil));
                    }
                }else{
                    completion(error:NSError(domain: "HTTP POST", code: 480, userInfo: nil));
                }
                
            })
            
            task.resume()
        }
        else{
            completion(error:NSError(domain:"ImageData", code: 477, userInfo: nil));
        }
    }
    
}
