//
//  MRNavigationBarProgressView.m
//  MRNavigationBarProgressView
//
//  Created by Marius Rackwitz on 09.10.13.
//  Copyright (c) 2013 Marius Rackwitz. All rights reserved.
//

#import "MRNavigationBarProgressView.h"
#import "MRMessageInterceptor.h"
#import <objc/runtime.h>


@interface UINavigationController (NavigationBarProgressView_Private)

@property (nonatomic, weak) MRNavigationBarProgressView *progressView;

@end


@implementation UINavigationController (NavigationBarProgressView_Private)

- (void)setProgressView:(MRNavigationBarProgressView *)progressView {
    objc_setAssociatedObject(self, @selector(progressView), progressView, OBJC_ASSOCIATION_ASSIGN);
}

- (MRNavigationBarProgressView *)progressView {
    return objc_getAssociatedObject(self, @selector(progressView));
}

@end



@interface MRNavigationBarProgressView () <UINavigationControllerDelegate>

@property (nonatomic, weak, readwrite) UIView *progressView;
@property (nonatomic, weak, readwrite) UIViewController *viewController;
@property (nonatomic, weak, readwrite) UIView *barView;

@end


@implementation MRNavigationBarProgressView

static void *MRNavigationBarProgressViewObservationContext = &MRNavigationBarProgressViewObservationContext;

+ (instancetype)progressViewForNavigationController:(UINavigationController *)navigationController {
    // Try to get existing bar
    MRNavigationBarProgressView *progressView = navigationController.progressView;
    if (progressView) {
        return progressView;
    }
    
    // Create new bar
    UINavigationBar *navigationBar = navigationController.navigationBar;
    progressView = [MRNavigationBarProgressView new];
    progressView.barView = navigationBar;
    
    progressView.progressTintColor = [UIColor redColor];//navigationBar.tintColor
//        ?: UIApplication.sharedApplication.delegate.window.tintColor;
    
    // Store bar and add to view hierachy
    navigationController.progressView = progressView;
    [navigationController.navigationBar addSubview:progressView];
    
    // Observe topItem
    progressView.viewController = navigationController.topViewController;
    id delegate = navigationController.delegate;
    if (delegate) {
        MRMessageInterceptor *messageInterceptor = [[MRMessageInterceptor alloc] initWithMiddleMan:progressView];
        messageInterceptor.receiver = delegate;
        navigationController.delegate = (id<UINavigationControllerDelegate>)messageInterceptor;
    } else {
        navigationController.delegate = progressView;
    }
    
    return progressView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)commonInit {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.opaque = NO;
    
    UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.bounds.size.height)];
    progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    progressView.backgroundColor = self.tintColor;
    [self addSubview:progressView];
    self.progressView = progressView;
    
    self.progress = 0;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // Check if our controller is still the topViewController or was popped
    NSUInteger index = [navigationController.viewControllers indexOfObject:self.viewController];
    if (index == NSNotFound || index < navigationController.viewControllers.count-1) {
        if ([((id<NSObject>)navigationController.delegate) isKindOfClass:MRMessageInterceptor.class]) {
            // Stop intercepting navigationBar.delegate messages
            id receiver = ((MRMessageInterceptor *)navigationController.delegate).receiver;
            navigationController.delegate = receiver != self ? receiver : nil;
            
            // Forward intercepted message
            [navigationController.delegate navigationController:navigationController willShowViewController:viewController animated:animated];
        } else {
            navigationController.delegate = nil;
        }
        
        // Remove reference
        navigationController.progressView = nil;
        
        // Remove receiver from view hierachy
        [self removeFromSuperview];
    }
}

- (void)setBarView:(UIView *)barView {
    _barView = barView;
    [self layoutSubviews];
}


#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect barFrame = self.barView.frame;
    const CGFloat progressBarHeight = 2;
    
    CGRect frame = CGRectMake(barFrame.origin.x,
                              0,
                              barFrame.size.width,
                              progressBarHeight);
    
    if ([self.barView isKindOfClass:UINavigationBar.class]) {
        const CGFloat barBorderHeight = 0.5;
        frame.origin.y = barFrame.size.height - progressBarHeight + barBorderHeight;
    }
    
    if (!CGRectEqualToRect(self.frame, frame)) {
        self.frame = frame;
    }
    
    [self layoutProgressView];
}

- (void)layoutProgressView {
    self.progressView.frame = CGRectMake(0, 0, self.frame.size.width * self.progress, self.frame.size.height);
}


#pragma mark - Getter and setter for progress tint color

- (void)setProgressTintColor:(UIColor *)tintColor {
    self.progressView.backgroundColor = tintColor;
}

- (UIColor *)progressTintColor {
    return self.progressView.backgroundColor;
}


#pragma mark - Control progress

- (void)setProgress:(float)progress {
    NSParameterAssert(progress >= 0 && progress <= 1);
    [self _setProgress:progress];
}

- (void)_setProgress:(float)progress {
    _progress = progress;
    [self progressDidChange];
}

- (void)progressDidChange {
    self.progressView.alpha = self.progress >= 1 ? 0 : 1;
    [self layoutProgressView];
}

- (void)setProgress:(float)progress animated:(BOOL)animated {
    if (animated) {
        if (progress > 0 && progress < 1.0 && self.progressView.alpha == 0) {
            // progressView was hidden. Make it visible first.
            self.progressView.alpha = 1;
        }
        
        void(^completion)(BOOL) = ^(BOOL finished){
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.progressView.alpha = progress >= 1 ? 0 : 1;
            } completion:nil];
        };
        
        if (progress > self.progress || self.progress == 1) {
            // Progress increased: ease out.
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self _setProgress:progress];
            } completion:completion];
        } else {
            // Progress decreased: bounce.
            [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:0 animations:^{
                [self _setProgress:progress];
            } completion:completion];
        }
    } else {
        self.progress = progress;
    }
}

@end
