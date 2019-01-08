//
//  CaptionLabel.swift
//  Telepic
//
//  Created by Kevin Wood on 11/5/18.
//  Copyright © 2018 Telepic LLC. All rights reserved.
//

import UIKit
import ActiveLabel

protocol CaptionLabelDelegate: class {
    func didTapURL(captionLabel: CaptionLabel, url: URL)
    func didTapCustom(captionLabel: CaptionLabel)
}

class CaptionLabel: ActiveLabel {
    
    weak var captionDelegate: CaptionLabelDelegate?
    
    var pretext: String! {
        didSet {
            let shortenedText = "\(pretext.prefix(95)) ...More"
            self.text = shortenedText
        }
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        let customType = ActiveType.custom(pattern: "\\s...More\\b")
        self.enabledTypes = [.url, customType]
        self.handleURLTap { (url) in
            self.captionDelegate?.didTapURL(captionLabel: self, url: url)
        }
        self.handleCustomTap(for: customType) { (_) in
            self.captionDelegate?.didTapCustom(captionLabel: self)
        }
    }
}
