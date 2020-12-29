//
//  BounceAnimationController.swift
//  StoreSearch12
//
//  Created by Buck Rozelle on 12/26/20.
//

import UIKit

class BounceAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
//Sets animation duration
func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.4
  }
//Performs actual animation
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    if let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
      let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
      let containerView = transitionContext.containerView
        toView.frame = transitionContext.finalFrame(for: toViewController)
      containerView.addSubview(toView)
      toView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
//Animation starts here.
      UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext),
                              delay: 0,
                              options: .calculationModeCubic,
                              animations: {
          UIView.addKeyframe(withRelativeStartTime: 0.0,
                             relativeDuration: 0.334) {
              toView.transform = CGAffineTransform(scaleX: 1.2,
                                                   y: 1.2)
          }
          UIView.addKeyframe(withRelativeStartTime: 0.334,
                             relativeDuration: 0.333) {
              toView.transform = CGAffineTransform(scaleX: 0.9,
                                                   y: 0.9)
          }
          UIView.addKeyframe(withRelativeStartTime: 0.666,
                             relativeDuration: 0.333) {
              toView.transform = CGAffineTransform(scaleX: 1.0,
                                                   y: 1.0)
          }
        }, completion: { finished in
          transitionContext.completeTransition(finished)
        })
    }
  }
}
