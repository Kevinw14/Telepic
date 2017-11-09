//
//  UserSettings.swift
//  Telepic
//
//  Created by Michael Bart on 10/9/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import Foundation

class UserSettings {
    class func saveOnboardingFinished() {
        UserDefaults.standard.set(true, forKey: "onboardingFinished")
        UserDefaults.standard.synchronize()
    }
    
    class func isOnboardingFinished() -> Bool {
        return UserDefaults.standard.bool(forKey: "onboardingFinished")
    }
}
