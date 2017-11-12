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
                
                FacebookGoogleClient.instance.parseFacebookFriendsData(completion: { (data, error) in
                    guard error == nil else { print(error!.localizedDescription); return }
  
                    if let data = data {
                        self.friends = data
                        
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "segueToInviteVC", sender: self)
                        }
                    }
                    
                
                })
            }
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

        FacebookGoogleClient
            .instance
            .getGoogleFriendsInfo(authToken: GIDSignIn.sharedInstance().currentUser.authentication!){ data, error in
            
                if let data = data {
                    self.friends = data
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "segueToInviteVC", sender: self)
                    }
                }
   
        }

    }
   
}











