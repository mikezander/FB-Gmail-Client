//
//  RoundedShadowButton.swift
//  Fb-Gmail Client
//
//  Created by Michael Alexander on 11/12/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit

class RoundedShadowButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView(){
        self.layer.cornerRadius = 5.0
        self.layer.shadowOpacity = 0.3
        self.layer.borderWidth = 0.1
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 5.0
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
    }

}
