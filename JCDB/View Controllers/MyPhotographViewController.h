//
//  MyPhotographViewController.h
//  JCDB
//
//  Created by WangJincai on 16/1/16.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^GetImageBlock)(UIImage *image);

@interface MyPhotographViewController : UIViewController


+ (MyPhotographViewController *)shareInstance;

- (void)viewController:(UIViewController*)viewController withBlock:(GetImageBlock) block;

@end
