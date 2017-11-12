//
//  LoginVC.swift
//  Fb-Gmail Client
//
//  Created by Michael Alexander on 11/9/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//
import UIKit
import FacebookCore
import FacebookLogin
import SwiftyJSON
import GoogleSignIn
import Google
import SWXMLHash

class LoginVC: UIViewController, XMLParserDelegate{

    var friends = [SocialFriend]()
    var googleClientId = "115814811542-ka0chf3bitargckp2sqmnc5a6opf79o6.apps.googleusercontent.com"

    @IBOutlet weak var fbButton: UIButton!
 
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().clientID = googleClientId
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.login")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.me")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/contacts.readonly")
        //GIDSignIn.sharedInstance().signInSilently()
    }

    @IBAction func gmailBtnWasPressed(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }

    @IBAction func fbBtnWasPressed(_ sender: Any) {
        
        let loginManager = LoginManager()
        
        loginManager.logIn(readPermissions: [.publicProfile,.email,.userFriends], viewController: self) { result in
            switch result {
            case .failed(let error):
                print(error.localizedDescription)
            case.cancelled:
                print("user cancelled the login")
            case.success(grantedPermissions: _, _, _):
                
                self.getFbFriendsInfo(completion: { userInfo, error in
                      if let error = error { print(error.localizedDescription) }
 
                        if let dictionary = userInfo, let dataDict = dictionary["data"] as? [Any]{
                            for data in dataDict{
                                
                                if let outer = data as? [String: Any], let picData = outer["picture"] as? [String: Any], let picData2 = picData["data"] as? [String: Any], let name = outer["name"] as? String, let url = picData2["url"] as? String {
                                    
                                    let friend = SocialFriend(name: name, url: url)
                                    self.friends.append(friend)
                                }
                            }
                            self.performSegue(withIdentifier: "segueToInviteVC", sender: self)
                        }
                    })
            }
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
 
    // Error 401 response
    func getGoogleFriendsInfo(completion: @escaping (_ : [SocialFriend]?, _ : Error?) -> Void) {
        
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
                            let accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken!
                            var tempFriends = [SocialFriend]()
                            for entry in entries {
                                
                                if let outer = entry as? [String: Any], let name = (outer["title"]) as? [String:Any], let userName = name["$t"] as? String {

                                    
                                    
                                    
                                    if let link = outer["link"] as?  [[String: Any]] {
                                        if let profileUrl = link[0]["href"] as? String {
                                            
                                            let url = "\(profileUrl)?access_token=\(accessToken)"
                                           
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
                           // self.performSegue(withIdentifier: "segueToInviteVC", sender: self)
                        }
                        
                        
                        /*let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                        let feed = json["feed"] as! [String: Any]
                        let entries = feed["entry"] as! [Any]
   
                        let accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken!
                        for entry in entries {
                           // print(entries[0])
                            
                            let outer = entry as! [String: Any]
    
                            let name = (outer["title"]) as? [String:Any]
                            let userName = name!["$t"] as! String
                            
                            if let link = outer["link"] as?  [[String: Any]] {
                                let profileUrl = "\(link[0]["href"]!)?access_token=\(accessToken)"
                                
                                
                                
                                
                                let friend = SocialFriend(name: userName, url: profileUrl)
                                print(friend)
                                
                                self.friends.append(friend)
                                
                            } */
                            
                                //if let email = outer["gd$email"] as? [[String: Any]]{
                                    //print("EMAIL \(email[0]["address"]!)")
                                    
                                    
                                    
                                //}
                            
                            //self.performSegue(withIdentifier: "segueToInviteVC", sender: self)

                            
                            //
                            
                            //let title = outer["title"] as! [String: Any]
                            //print(title["$t"])
                       // }
    
                    }catch let error as NSError{
                        print(error)
                    }
                    
                    
                }
                
                
            }).resume()
            
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToInviteVC" {
            let navVC = segue.destination as? UINavigationController
            let inviteVC = navVC?.viewControllers.first as! InviteVC
            inviteVC.friends = self.friends
        }
        
    }
}

extension LoginVC: GIDSignInDelegate, GIDSignInUIDelegate {
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        //activity indicator stop animating
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
         print(user.accessibleScopes)

        
        getGoogleFriendsInfo(){ data, error in
            self.friends = data!
 
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "segueToInviteVC", sender: self)
            }
            
        }

        //if let error = error {
         //   print(error.localizedDescription)
       // } else {
        
      //  }

    }
   
}











