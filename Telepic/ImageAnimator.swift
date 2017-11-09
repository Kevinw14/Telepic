//
//  ImageAnimator.swift
//  Telepic
//
//  Created by Michael Bart on 10/27/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class ImageAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let duration = 0.3
    var presenting = true
    var originFrame = CGRect.zero
    var dismissCompletion: (()->Void)?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        let containerView = transitionContext.containerView
//        let toView = transitionContext.view(forKey: .to)!
//        let imageView = presenting ? toView : transitionContext.view(forKey: .from)!
//
//        let initialFrame = presenting ? originFrame : imageView.frame
//        let finalFrame = presenting ? imageView.frame : originFrame
//
//        let xScaleFactor = presenting ? initialFrame.width / finalFrame.width : finalFrame.width / initialFrame.width
//        let yScaleFactor = presenting ? initialFrame.height / finalFrame.height : finalFrame.height / initialFrame.height
//
//        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
//
//        if presenting {
//            imageView.transform = scaleTransform
//            imageView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
//            imageView.clipsToBounds = true
//        }
//
//        if let toVC = transitionContext.viewController(forKey: .to) as? MediaViewVC {
//
//        }
//
//        containerView.addSubview(toView)
//        containerView.bringSubview(toFront: imageView)
//
//        UIView.animate(withDuration: duration, animations: {
//
//            imageView.transform = self.presenting ? CGAffineTransform.identity : scaleTransform
//            imageView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
//        }) { (_) in
//            if !self.presenting {
//                self.dismissCompletion?()
//            }
//            transitionContext.completeTransition(true)
//        }
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let imageView = presenting ? toView : transitionContext.view(forKey: .from)!

        toView.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            toView.alpha = 1
        })
        
        containerView.addSubview(toView)
        containerView.bringSubview(toFront: imageView)

        if !self.presenting {
            
            self.dismissCompletion?()
        }
        
        transitionContext.completeTransition(true)
    }
}
