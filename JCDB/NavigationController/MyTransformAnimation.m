//
//  PopAnimation.m
//  ViewControllerTransitions
//
//  Created by Jymn_Chen on 14-2-6.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//


#import "MyTransformAnimation.h"

@implementation MyTransformAnimation

#pragma mark - UIViewControllerAnimatedTransitioning Delegate

/* 动画切换的持续时间，以秒为单位 */
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1;
}

/* 动画的内容 */
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *desController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *srcController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:desController.view];
    desController.view.alpha = 0.0;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         srcController.view.transform = self.transform;
                         desController.view.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         srcController.view.transform = CGAffineTransformIdentity;
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}

@end
