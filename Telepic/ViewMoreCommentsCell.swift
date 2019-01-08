//
//  ViewMoreCommentsCell.swift
//  Telepic
//
//  Created by Kevin Wood on 11/6/18.
//  Copyright © 2018 Telepic LLC. All rights reserved.
//

import UIKit

class ViewMoreCommentsCell: UITableViewCell {
    
    init(numberOfComments: Int) {
        super .init(style: .default, reuseIdentifier: nil)
        self.selectionStyle = .none
        self.textLabel?.text = "View all \(numberOfComments) comments"
        self.textLabel?.font = UIFont(name: "SFProText-Light", size: 14)
        self.textLabel?.textColor = .gray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
