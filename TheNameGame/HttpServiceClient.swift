//
//  HttpServiceClient.swift
//  TheNameGame
//
//  Created by Alex Ramey on 2/26/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

import UIKit

class HttpServiceClient: NSObject {

    let rdsEndPoint = "http://ec2-54-167-192-170.compute-1.amazonaws.com/service.php";
    
    override init() {
        super.init()
        // custom initialization
    }
    
    func postData(_ image: UIImage, name: String, completion: @escaping (_ error: NSError?) -> Void){
        let request = NSMutableURLRequest(url: (URL(string:self.rdsEndPoint))!)
        let session = URLSession.shared
        request.httpMethod = "POST"
        if let imageData = UIImageJPEGRepresentation(image, 0.5)
        {
            // Create your request string with parameter name as defined in PHP file
            let requestString: String = "name=\(name)&imageData=\(imageData.base64EncodedString(options: []))"
            // Create Data from request
            let requestData: Data = Data(bytes: UnsafePointer<UInt8>(String(describing: requestString.utf8)), count: requestString.characters.count)
            // Set content-type
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
            request.httpBody = requestData
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                print("Response: \(response)")
                print("Error: \(error)")
                if (data != nil){
                    if let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                        print("Body: \(strData)")
                        if (strData == "success")
                        {
                            completion(nil)
                        }else{
                            completion(NSError(domain: "HTTP POST", code: 478, userInfo: nil));
                        }
                    }else{
                        completion(NSError(domain: "HTTP POST", code: 479, userInfo: nil));
                    }
                }else{
                    completion(NSError(domain: "HTTP POST", code: 480, userInfo: nil));
                }
                
            })
            
            task.resume()
        }
        else{
            completion(NSError(domain:"ImageData", code: 477, userInfo: nil));
        }
    }
    
    func getPeople(_ completion: @escaping (_ error: NSError?, _ people:NSDictionary?) -> Void){
        let request = NSMutableURLRequest(url: (URL(string:self.rdsEndPoint))!)
        let session = URLSession.shared
        request.httpMethod = "GET"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            print("Error: \(error)")
            if (data != nil){
                var jsonObject:NSDictionary? = nil
                do{
                    jsonObject = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                }catch{
                    print("failed to convert json")
                }
                if (jsonObject != nil)
                {
                    completion(nil, jsonObject)
                }else{
                    completion(NSError(domain: "HTTP GET", code: 471, userInfo: nil), nil);
                }
            }else{
                completion(NSError(domain: "HTTP GET", code: 472, userInfo: nil), nil);
            }
        })
            
        task.resume()
    }
    
    func getImage(_ personID:Int, completion: @escaping (_ error: NSError?, _ encodedImage:String?) -> Void){
        let request = NSMutableURLRequest(url: (URL(string:self.rdsEndPoint+"?id=\(personID)"))!)
        let session = URLSession.shared
        request.httpMethod = "GET"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            print("Error: \(error)")
            if (data != nil){
                var jsonObject:NSDictionary? = nil
                do{
                    jsonObject = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                }catch{
                    print("failed to convert json")
                }
                if (jsonObject != nil)
                {
                    completion(nil, (jsonObject!)["data"] as? String)
                }else{
                    completion(NSError(domain: "HTTP GET", code: 471, userInfo: nil), nil);
                }
            }else{
                completion(NSError(domain: "HTTP GET", code: 472, userInfo: nil), nil);
            }
        })
        
        task.resume()
    }
}
