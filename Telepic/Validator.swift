//
//  Validator.swift
//  Telepic
//
//  Created by Michael Bart on 10/4/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class Validator {
    
    func validate(email: String) -> String? {
        
        let trimmedText = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let dataDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return nil }
        
        let range = NSMakeRange(0, NSString(string: trimmedText).length)
        let allMatches = dataDetector.matches(in: trimmedText,
                                              options: [],
                                              range: range)
        
        if allMatches.count == 1,
            allMatches.first?.url?.absoluteString.contains("mailto:") == true
        {
            return trimmedText
        }
    
        return nil
    }
    
    func isPasswordValid(_ password: String) -> Bool {
        
//        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Za-z])(?=.*[0-9]).{6,}$")
        return passwordTest.evaluate(with: password)
    }
}
