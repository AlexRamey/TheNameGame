//
//  DataStore.swift
//  TheNameGame
//
//  Created by Alex Ramey on 2/27/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

import UIKit

// a nice extension from http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift
// this allows us to call suffleInPlace on mutable arrays which is super convenient for this app
extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

class DataStore: NSObject {
    
    // properties
    var gamePeople:[(Int, String)] = []
    var currentIndex = 0
    
    func reloadData(completion: (error: NSError?) -> Void){
        resetStateInformation()
        HttpServiceClient().getPeople { (error, people) -> Void in
            if (error == nil){
                if let peopleArray:Array<NSDictionary> = (people!.objectForKey("data") as! [NSDictionary]){
                    for personDictionary in peopleArray{
                        let key:String = (personDictionary.allKeys[0] as! String)
                        self.gamePeople.append((Int(key)!, personDictionary[key] as! String))
                    }
                    self.gamePeople.shuffleInPlace()
                }
            }
            completion(error: error)
        }
    }
    
    func nextPerson(completion:(error:NSError?, name:String, picture:UIImage?)->Void){
        // No more people left!
        if (self.currentIndex == self.gamePeople.count){
            completion(error:NSError(domain: "NoMorePeople", code: 444, userInfo: nil),name:"",picture:nil)
            return
        }
        
        // Fetch next person's image and then return the tuple
        HttpServiceClient().getImage(self.gamePeople[currentIndex].0) { (error, encodedImage) -> Void in
            if ((error == nil) && (encodedImage != nil)){
                // Note, + signs in the base64 encoding got converted to spaces
                // during the HTTP POST to the DB. Convert back here before decoding.
                let fixedEncoding = encodedImage!.stringByReplacingOccurrencesOfString(" ", withString: "+")
                if let data = NSData(base64EncodedString:fixedEncoding, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters){
                    completion(error:nil, name:self.gamePeople[self.currentIndex].1, picture:UIImage(data: data))
                    self.currentIndex += 1
                }
                else
                {
                    completion(error:NSError(domain:"ImageFetch", code: 435, userInfo: nil), name:"", picture: nil)
                }
            }else{
                completion(error:NSError(domain:"ImageFetch", code: error?.code ?? 433, userInfo: nil), name:"", picture: nil)
            }
        }
    }
    
    // helper function
    func resetStateInformation(){
        gamePeople = []
        currentIndex = 0
    }
    
    
    // useful function for generating the other three choices
    func threeRandomNamesOtherThan(name:String)->(String,String,String){
        var otherNames:[String] = []
        for tuple in self.gamePeople{
            otherNames.append(tuple.1)
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
