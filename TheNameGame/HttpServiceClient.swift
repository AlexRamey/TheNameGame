//
//  HttpServiceClient.swift
//  TheNameGame
//
//  Created by Alex Ramey on 2/26/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

import UIKit

class HttpServiceClient: NSObject {

    let rdsEndPoint = "http://ec2-52-91-103-99.compute-1.amazonaws.com/service.php";
    
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
            let requestString: String = "name=\(name)&imageData=\(imageData.base64EncodedStringWithOptions([]))"
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
    
    func getPeople(completion: (error: NSError?, people:NSDictionary?) -> Void){
        let request = NSMutableURLRequest(URL: (NSURL(string:self.rdsEndPoint))!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            print("Error: \(error)")
            if (data != nil){
                var jsonObject:NSDictionary? = nil
                do{
                    jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                }catch{
                    print("failed to convert json")
                }
                if (jsonObject != nil)
                {
                    completion(error:nil, people:jsonObject)
                }else{
                    completion(error:NSError(domain: "HTTP GET", code: 471, userInfo: nil), people:nil);
                }
            }else{
                completion(error:NSError(domain: "HTTP GET", code: 472, userInfo: nil), people:nil);
            }
        })
            
        task.resume()
    }
    
    func getImage(personID:Int, completion: (error: NSError?, encodedImage:String?) -> Void){
        let request = NSMutableURLRequest(URL: (NSURL(string:self.rdsEndPoint+"?id=\(personID)"))!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            print("Error: \(error)")
            if (data != nil){
                var jsonObject:NSDictionary? = nil
                do{
                    jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                }catch{
                    print("failed to convert json")
                }
                if (jsonObject != nil)
                {
                    completion(error:nil, encodedImage:(jsonObject!)["data"] as? String)
                }else{
                    completion(error:NSError(domain: "HTTP GET", code: 471, userInfo: nil), encodedImage:nil);
                }
            }else{
                completion(error:NSError(domain: "HTTP GET", code: 472, userInfo: nil), encodedImage:nil);
            }
        })
        
        task.resume()
    }
}
