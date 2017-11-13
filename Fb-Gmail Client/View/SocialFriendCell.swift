//
//  SocialFriendCell.swift
//  Fb-Gmail Client
//
//  Created by Michael Alexander on 11/9/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import SDWebImage

class SocialFriendCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var inviteFlagBtn: UIButton!
    
    func configCell(friend: SocialFriend) {
        inviteFlagBtn.isHidden = (!friend.inviteFlag)

        profilePic.sd_setImage(with: URL(string: friend.url),placeholderImage: UIImage(named: "profile-placeholder"))
        
        if friend.email != nil {
            emailLbl.text = friend.email!
        } else if friend.phoneNumber != nil{
            emailLbl.text = friend.phoneNumber
        } else {
            emailLbl.text = ""
        }
        
        if friend.name == "" && friend.email != nil{
            nameLbl.text = friend.email
            emailLbl.text = ""
        }else {
            nameLbl.text = friend.name
        }
    }
    
    func toggleInviteButton(flag: Bool) {
        if flag {
            inviteFlagBtn.isHidden = false
            inviteFlagBtn.alpha = 1.0
        } else {
            inviteFlagBtn.alpha = 0.0
            inviteFlagBtn.isHidden = true
            
        }
    }
    
}
