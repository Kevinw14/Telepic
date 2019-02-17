//
//  ImageAnimator.swift
//  Telepic
//
//  Created by Michael Bart on 10/27/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class ImageAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let duration = 0.5
    var presenting = true
    
    var originFrame = CGRect.zero
    var dismissCompletion: (()->Void)?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let imageView = presenting ? toView : transitionContext.view(forKey: .from)!

        toView.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            toView.alpha = 1
        })
        
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(imageView)

        if !self.presenting {
            
            self.dismissCompletion?()
        }
        
        transitionContext.completeTransition(true)
    }
}
