//
//  AppDelegate.h
//  JCDB
//
//  Created by WangJincai on 15/12/31.
//  Copyright © 2015年 WJC.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)addTabBarController;
- (void)loginView;

- (void)cancelLocalNotification;

@end

