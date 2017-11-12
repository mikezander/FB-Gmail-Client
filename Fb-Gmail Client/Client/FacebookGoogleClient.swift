//
//  FacebookGoogleClient.swift
//  Fb-Gmail Client
//
//  Created by Michael Alexander on 11/12/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import GoogleSignIn
import Google
import FacebookCore
import FacebookLogin

class FacebookGoogleClient {
    
    static let instance = FacebookGoogleClient()
    
    func getGoogleFriendsInfo(authToken: GIDAuthentication, completion: @escaping (_ : [SocialFriend]?, _ : Error?) -> Void) {
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            
            let urlString = ("https://www.google.com/m8/feeds/contacts/default/full?alt=json&max-results=50&access_token=\(GIDSignIn.sharedInstance().currentUser.authentication.accessToken!)")
            
            let url = URL(string: urlString)!
            URLSession.shared.dataTask(with: url, completionHandler: {
                (data, response, error) in
                
                if(error != nil){
                    print("error")
                }else{
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                        
                        if let feed = json["feed"] as? [String: Any], let entries = feed["entry"] as? [Any] {
                            //let accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken!
                            var tempFriends = [SocialFriend]()
                            for entry in entries {
                                
                                if let outer = entry as? [String: Any], let name = (outer["title"]) as? [String:Any], let userName = name["$t"] as? String {
                                    
                                    if let link = outer["link"] as?  [[String: Any]] {
                                        if let profileUrl = link[0]["href"] as? String {
                                            
                                            let url = "\(profileUrl)?access_token=\(authToken)"
                                            
                                            // Gmail Contacts
                                            if let email = outer["gd$email"] as? [[String: Any]]{
                                                let emailAddress = email[0]["address"] as! String
                                                let friend = SocialFriend(name: userName, url: url, email: emailAddress)
                                                tempFriends.append(friend)
                                                
                                            } else if let phone = outer["gd$phoneNumber"] as? [[String:Any]]{
                                                let phoneNumber = phone[0]["$t"] as! String
                                                let friend = SocialFriend(name: userName, url: url, phoneNumber: phoneNumber)
                                                tempFriends.append(friend)
                                                
                                            } else {
                                                let friend = SocialFriend(name: userName, url: url)
                                                tempFriends.append(friend)
                                            }
                                            
                                        }
                                    }
                                }
                            }
                            completion(tempFriends, error)
                        }
                        
                    }catch let error as NSError{
                        print(error)
                    }
                }
            }).resume()
        }
        
    }
    
    func getFbFriendsInfo(completion: @escaping (_ : [String: Any]?, _ : Error?) -> Void) {
        let params = ["fields": ""]
        
        let request = GraphRequest(graphPath: "me/taggable_friends?limit=5000", parameters: params)
        
        request.start { (response, result) in
            switch result {
            case .failed(let error):
                completion(nil, error)
            case.success(let graphResponse):
                completion(graphResponse.dictionaryValue, nil)
            }
        }
    }
    
    func parseFacebookFriendsData(completion: @escaping (_ : [SocialFriend]?, _ : Error?) -> Void) {
        self.getFbFriendsInfo(completion: { userInfo, error in
            if let error = error { print(error.localizedDescription) }
            
            if let dictionary = userInfo, let dataDict = dictionary["data"] as? [Any]{
                var tempFriends = [SocialFriend]()
                for data in dataDict{
                    
                    if let outer = data as? [String: Any], let picData = outer["picture"] as? [String: Any], let picData2 = picData["data"] as? [String: Any], let name = outer["name"] as? String, let url = picData2["url"] as? String {
                        
                        let friend = SocialFriend(name: name, url: url)
                        tempFriends.append(friend)
                    }
                }
                completion(tempFriends, error)
            }
        })
    }
}
