//
//  CustomNavigationController.swift
//  Telepic
//
//  Created by Michael Bart on 11/9/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {

//    var isPushingViewController = false
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // 3
//        delegate = self
//        // 5
//        interactivePopGestureRecognizer?.delegate = self
//    }
//    
//    // 2
//    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
//        isPushingViewController = true
//        super.pushViewController(viewController, animated: animated)
//    }
//}
//
//// 6
//extension CustomNavigationController: UIGestureRecognizerDelegate {
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        guard gestureRecognizer is UIScreenEdgePanGestureRecognizer else { return true }
//        return viewControllers.count > 1 && !isPushingViewController
//    }
//}
//
//// 4
//extension CustomNavigationController: UINavigationControllerDelegate {
//    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        isPushingViewController = false
//    }
}
