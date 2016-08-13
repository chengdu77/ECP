//
//  NotiSettingViewController.h
//  xsgj
//
//  Created by NewDoone on 14-10-13.
//  Copyright (c) 2014年 ilikeido. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeadViewController.h"

@interface NotiSettingViewController : HeadViewController


@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *txView;
@property (weak, nonatomic) IBOutlet UIImageView *txImageView;

@property (weak, nonatomic) IBOutlet UIButton *modifyPasswordButton;
@property (strong, nonatomic) IBOutlet UIButton *abortButton;


@end
