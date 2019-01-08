//
//  CaptionCell.swift
//  Telepic
//
//  Created by Kevin Wood on 11/6/18.
//  Copyright © 2018 Telepic LLC. All rights reserved.
//

import UIKit

class CaptionCell: UITableViewCell {
    
    let commentLabel: CaptionLabel = {
        let label = CaptionLabel()
        label.font = UIFont(name: "SFProText-Light", size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    init(caption: String, creatorAvatarURL: String) {
        super .init(style: .default, reuseIdentifier: nil)
        self.commentLabel.text = caption
        self.selectionStyle = .none
        guard let url = URL(string: creatorAvatarURL) else { return }
        FirebaseController.shared.fetchAvatarImage(creatorAvatarURL: url) { (image) in
            self.avatarImageView.image = image
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super .layoutSubviews()
        addSubview(commentLabel)
        addSubview(avatarImageView)
        
        avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        avatarImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor).isActive = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        
        commentLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8).isActive = true
        commentLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8).isActive = true
        commentLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
