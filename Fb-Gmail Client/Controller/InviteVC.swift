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
}

extension InviteVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchtext(searchController.searchBar.text!)
    }
}
