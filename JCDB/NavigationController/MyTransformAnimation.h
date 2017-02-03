//
//  PopAnimation.h
//  ViewControllerTransitions
//
//  Created by Jymn_Chen on 14-2-6.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTransformAnimation : NSObject <UIViewControllerAnimatedTransitioning>


@property (nonatomic,assign) CGAffineTransform transform;

@end
