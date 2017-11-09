//
//  CustomPopTransition.swift
//  Telepic
//
//  Created by Michael Bart on 11/8/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class CustomPopTransition: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        let containerView = transitionContext.containerView
//        let fromViewController = transitionContext.viewController(forKey: .from)
//        let toViewController = transitionContext.viewController(forKey: .to)
//        guard let fromVc = fromViewController,
//            let toVc = toViewController,
//            let snapshotView = fromVc.view.snapshotView(afterScreenUpdates: false)
//            else { return }
//        let finalFrame = transitionContext.finalFrame(for: fromVc)
//        toVc.view.frame = finalFrame
//        containerView.addSubview(toVc.view)
//        containerView.sendSubview(toBack: toVc.view)
//        snapshotView.frame = fromVc.view.frame
//        containerView.addSubview(snapshotView)
//        fromVc.view.removeFromSuperview()
//        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
//            //Below line will start from right
//            snapshotView.frame = finalFrame.offsetBy(dx: -finalFrame.size.width, dy: 0)
//        }, completion: {(finished) in
//            snapshotView.removeFromSuperview()
//            transitionContext.completeTransition(finished)
//        })
        let containerVw = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: .from)
        let toViewController = transitionContext.viewController(forKey: .to)
        guard let fromVc = fromViewController, let toVc = toViewController else { return }
        let finalFrame = transitionContext.finalFrame(for: toVc)
        //Below line will start from left
        toVc.view.frame = finalFrame.offsetBy(dx: -finalFrame.size.width, dy: 0)
        containerVw.addSubview(toVc.view)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toVc.view.frame = finalFrame
            fromVc.view.frame = finalFrame.offsetBy(dx: finalFrame.size.width, dy: 0)
            fromVc.view.alpha = 0.5
        }, completion: {(finished) in
            transitionContext.completeTransition(finished)
            fromVc.view.alpha = 1.0
        })
    }
}
