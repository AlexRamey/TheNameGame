//
//  DataStore.swift
//  TheNameGame
//
//  Created by Alex Ramey on 2/27/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

import UIKit

// a nice extension from http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift
// this allows us to call shuffleInPlace on mutable arrays which is super convenient for this app
extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in startIndex ..< endIndex {
            let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

class DataStore: NSObject {
    
    // properties
    var gamePeople:[(Int, String)] = []
    var currentIndex = 0
    
    func reloadData(_ completion: @escaping (_ error: NSError?) -> Void){
        resetStateInformation()
        HttpServiceClient().getPeople { (error, people) -> Void in
            if (error == nil){
                if let peopleArray:Array<NSDictionary> = (people!.object(forKey: "data") as? [NSDictionary]){
                    for personDictionary in peopleArray{
                        let key:String = (personDictionary.allKeys[0] as! String)
                        self.gamePeople.append((Int(key)!, personDictionary[key] as! String))
                    }
                    self.gamePeople.shuffleInPlace()
                }
            }
            completion(error)
        }
    }
    
    func nextPerson(_ completion:@escaping (_ error:NSError?, _ name:String, _ picture:UIImage?)->Void){
        // No more people left!
        if (self.currentIndex == self.gamePeople.count){
            completion(NSError(domain: "NoMorePeople", code: 444, userInfo: nil),"",nil)
            return
        }
        
        // Fetch next person's image and then return the tuple
        HttpServiceClient().getImage(self.gamePeople[currentIndex].0) { (error, encodedImage) -> Void in
            if ((error == nil) && (encodedImage != nil)){
                // Note, + signs in the base64 encoding got converted to spaces
                // during the HTTP POST to the DB. Convert back here before decoding.
                let fixedEncoding = encodedImage!.replacingOccurrences(of: " ", with: "+")
                if let data = Data(base64Encoded:fixedEncoding, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters){
                    completion(nil, self.gamePeople[self.currentIndex].1, UIImage(data: data))
                    self.currentIndex += 1
                }
                else
                {
                    completion(NSError(domain:"ImageFetch", code: 435, userInfo: nil), "", nil)
                }
            }else{
                completion(NSError(domain:"ImageFetch", code: error?.code ?? 433, userInfo: nil), "", nil)
            }
        }
    }
    
    // helper function
    func resetStateInformation(){
        gamePeople = []
        currentIndex = 0
    }
    
    
    // useful function for generating the other three choices
    func threeRandomNamesOtherThan(_ name:String)->(String,String,String){
        var otherNames:[String] = []
        for tuple in self.gamePeople{
            if tuple.1 != name{
                otherNames.append(tuple.1)
            }
        }
        otherNames.shuffleInPlace()
        switch(otherNames.count){
        case 0:
            return ("🎅🏿","👶🏼","🙃")
        case 1:
            return (otherNames[0],"🎅🏿","🙃")
        case 2:
            return (otherNames[0],otherNames[1],"🎅🏿")
        default:
            return (otherNames[0],otherNames[1],otherNames[2])
        }
    }
}
