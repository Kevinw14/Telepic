//
//  ZoomTransitioningDelegate.swift
//  Telepic
//
//  Created by Michael Bart on 12/4/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

@objc protocol ZoomingViewController {
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView?
    func zoomingBackgroundView(for transition: ZoomTransitioningDelegate) -> UIView?
}

enum TransitionState {
    case initial
    case final
}

class ZoomTransitioningDelegate: NSObject {
    var transitionDuration = 0.5
    var operation: UINavigationControllerOperation = .none
    private let zoomScale = CGFloat(15)
    private let backgroundScale = CGFloat(0.7)
    
    typealias ZoomingViews = (otherView: UIView, imageView: UIView)
    
    func configureViews(for state: TransitionState, containerView: UIView, backgroundViewController: UIViewController, viewsInBackground: ZoomingViews, viewsInForeground: ZoomingViews, snapshotViews: ZoomingViews) {
        switch state {
        case .initial:
            backgroundViewController.view.transform = CGAffineTransform.identity
            backgroundViewController.view.alpha = 1
            
            snapshotViews.imageView.frame = containerView.convert(viewsInBackground.imageView.frame, from: viewsInBackground.imageView.superview)
        case .final:
            //backgroundViewController.view.transform = CGAffineTransform(scaleX: backgroundScale, y: backgroundScale)
            backgroundViewController.view.alpha = 0
            
            snapshotViews.imageView.frame = containerView.convert(viewsInForeground.imageView.frame, from: viewsInForeground.imageView.superview)
        }
    }
}

extension ZoomTransitioningDelegate: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!
        let containerView = transitionContext.containerView
        
        var backgroundVC = fromVC
        var foregroundVC = toVC
        
        if operation == .pop {
            backgroundVC = toVC
            foregroundVC = fromVC
        }
        
        let possibleBackgroundImageView = (backgroundVC as? ZoomingViewController)?.zoomingImageView(for: self)
        let possibleForegroundImageView = (foregroundVC as? ZoomingViewController)?.zoomingImageView(for: self)
        
        assert(possibleBackgroundImageView != nil, "Cannot find imageView in backgroundVC")
        assert(possibleForegroundImageView != nil, "Cannot find imageView in foregroundVC")
        
        let backgroundImageView = possibleBackgroundImageView!
        let foregroundImageView = possibleForegroundImageView!
        
        let imageViewSnapshot = UIImageView(image: backgroundImageView.image)
        imageViewSnapshot.contentMode = backgroundImageView.contentMode
        imageViewSnapshot.layer.masksToBounds = true
        
        backgroundImageView.isHidden = true
        foregroundImageView.isHidden = true
        let foregroundViewBackgroundColor = foregroundVC.view.backgroundColor
        foregroundVC.view.backgroundColor = .clear
        containerView.backgroundColor = .black
        
        containerView.addSubview(backgroundVC.view)
        containerView.addSubview(foregroundVC.view)
        containerView.addSubview(imageViewSnapshot)
        
        var preTransitionState = TransitionState.initial
        var postTransitionState = TransitionState.final
        
        if operation == .pop {
            preTransitionState = .final
            postTransitionState = .initial
        }
        
        configureViews(for: preTransitionState, containerView: containerView, backgroundViewController: backgroundVC, viewsInBackground: (backgroundImageView, backgroundImageView), viewsInForeground: (foregroundImageView, foregroundImageView), snapshotViews: (imageViewSnapshot, imageViewSnapshot))
        
        foregroundVC.view.layoutIfNeeded()
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            self.configureViews(for: postTransitionState, containerView: containerView, backgroundViewController: backgroundVC, viewsInBackground: (backgroundImageView, backgroundImageView), viewsInForeground: (foregroundImageView, foregroundImageView), snapshotViews: (imageViewSnapshot, imageViewSnapshot))
        }) { (finished) in
            
            backgroundVC.view.transform = CGAffineTransform.identity
            imageViewSnapshot.removeFromSuperview()
            backgroundImageView.isHidden = false
            foregroundImageView.isHidden = false
            foregroundVC.view.backgroundColor = foregroundViewBackgroundColor
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

extension ZoomTransitioningDelegate: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let isZooming = FirebaseController.shared.isZooming
        if fromVC is ZoomingViewController && toVC is ZoomingViewController && isZooming {
            self.operation = operation
            return self
        } else {
            return nil
        }
    }
}

