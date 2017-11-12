//
//  SocialFriends.swift
//  Fb-Gmail Client
//
//  Created by Michael Alexander on 11/9/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation

struct SocialFriend {
    
    var name: String
    var url: String
    var email: String?
    var phoneNumber: String?
    
    init(name: String, url: String, email: String? = nil, phoneNumber: String? = nil) {

        self.name = name
        self.url = url
        self.email = email
        self.phoneNumber = phoneNumber
    }
}
