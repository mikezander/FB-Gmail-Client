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
    let searchController = UISearchController(searchResultsController: nil)

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
    
    @IBAction func invitePressed(_ sender: Any) {
        sendEmailInvitations()
        
        sendTextInviatations()
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
    
    func sendEmailInvitations() {
        if (MFMailComposeViewController.canSendMail()) {
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self
            mailVC.setToRecipients(["mikezander87@yahoo.com"])
            mailVC.setSubject("test")
            mailVC.setMessageBody("fdsfsdfsdfsdfsdf", isHTML: false)
            self.present(mailVC, animated: true, completion: nil)
        }
        
    }
    
    func sendTextInviatations() {
        if (MFMessageComposeViewController.canSendText()) {
            let messageVC = MFMessageComposeViewController()
            messageVC.body = "https://itunes.apple.com/us/app/sk8spots-skate-spots-app/id1281370899?mt=8"
            messageVC.recipients = ["19143107144"]
            messageVC.messageComposeDelegate = self
            self.present(messageVC, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
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
