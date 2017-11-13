//
//  InviteVC.swift
//  Fb-Gmail Client
//
//  Created by Michael Alexander on 11/9/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//
import UIKit
import GoogleSignIn
import FBSDKShareKit
import MessageUI

class InviteVC: UIViewController{
    
    var friends = [SocialFriend]()
    var filteredFriends = [SocialFriend]()
    var emailsOfFriends = [SocialFriend]()
    var phoneNumberOfFriends = [SocialFriend]()
    let searchController = UISearchController(searchResultsController: nil)
    var isFacebook = Bool()

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search friends"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func invitePressed(_ sender: Any) {
        
        getEmailsAndPhoneNumbers()
       
        let actionSheet = UIAlertController(title: "Invitation Source", message: "Choose a source", preferredStyle: .actionSheet)
       
        actionSheet.addAction(UIAlertAction(title: "Email \(emailsOfFriends.count) friends", style: .default, handler: { (action:UIAlertAction) in
            
            if !self.emailsOfFriends.isEmpty {
                self.sendEmailInvitations(friends: self.emailsOfFriends)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Text \(phoneNumberOfFriends.count) friends", style: .default, handler: { (action:UIAlertAction) in
            
            if !self.phoneNumberOfFriends.isEmpty {
                self.sendTextInviatations(friends: self.phoneNumberOfFriends)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        
        actionSheet.popoverPresentationController?.sourceView = self.view
        actionSheet.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        present(actionSheet, animated: true, completion: nil)
    }

    func searchBarisEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchtext(_ searchText: String, scope: String = "All") {
        filteredFriends = friends.filter({ (friend: SocialFriend) -> Bool in
            return friend.name.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarisEmpty()
    }
    
    // REQUIRES FACEBOOK APPROVAL BEFORE USAGE
    //https://stackoverflow.com/questions/31165632/facebook-app-invite-dialog-not-working
    
    func getEmailsAndPhoneNumbers() {
        for friend in friends {
            
            if friend.inviteFlag == true {
                
                if let _ = friend.email {
                    emailsOfFriends.append(friend)

                }
                
                if let _ = friend.phoneNumber {
                    phoneNumberOfFriends.append(friend)

                }
            }

        }
        
        if isFacebook{
            let alert = UIAlertController(title: "FB Authorization needed", message: "In order to sens SMS app invitations with Facebook you must go through Facebook review first.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
   
}

extension InviteVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredFriends.count
        }
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var friend = friends[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as! SocialFriendCell
        
        if isFiltering() {
            friend = filteredFriends[indexPath.row]
        }else {
            friend = friends[indexPath.row]
        }

        cell.configCell(friend: friend)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as! SocialFriendCell
        
        let friend = friends[indexPath.row]
        friend.toggleFlag(flag: !friend.inviteFlag)
        
        cell.toggleInviteButton(flag: friend.inviteFlag)
 
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        tableView.endUpdates()
    }
    
}

extension InviteVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchtext(searchController.searchBar.text!)
    }
}

extension InviteVC: MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    func sendEmailInvitations(friends: [SocialFriend]) {
        var emails = [String]()
        for friend in friends {
            emails.append(friend.email!)
            friend.inviteFlag = false
        }

        if (MFMailComposeViewController.canSendMail()) {
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self
            mailVC.setToRecipients(["mikezander87@yahoo.com"])
            mailVC.setSubject("App Invitation")
            mailVC.setMessageBody("Check out this cool app I've been using! \n https://itunes.apple.com/us/app/sk8spots-skate-spots-app/id1281370899?mt=8", isHTML: false)
            self.present(mailVC, animated: true, completion: nil)
        }
        
    }
    
    func sendTextInviatations(friends: [SocialFriend]) {
        var phoneNumbers = [String]()
        for friend in friends {
            phoneNumbers.append(friend.phoneNumber!)
            friend.inviteFlag = false
        }
        if (MFMessageComposeViewController.canSendText()) {
            let messageVC = MFMessageComposeViewController()
            messageVC.body = "https://itunes.apple.com/us/app/sk8spots-skate-spots-app/id1281370899?mt=8"
            messageVC.recipients = phoneNumbers
            messageVC.messageComposeDelegate = self
            self.present(messageVC, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        emailsOfFriends.removeAll()
        switch (result.rawValue) {
        case MFMailComposeResult.cancelled.rawValue:
            print("Message was cancelled")
            self.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.failed.rawValue:
            print("Message failed")
            self.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.sent.rawValue:
            print("Message was sent")
            self.dismiss(animated: true, completion: nil)
        default:
            break;
        }
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        phoneNumberOfFriends.removeAll()
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            print("Message was cancelled")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            print("Message failed")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            print("Message was sent")
            self.dismiss(animated: true, completion: nil)
        default:
            break;
        }
    }
}
