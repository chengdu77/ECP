//
//  AboutViewController.h
//  xsgj
//
//  Created by Geory on 14-7-24.
//  Copyright (c) 2014年 ilikeido. All rights reserved.
//

#import "HeadViewController.h"

@interface AboutViewController : HeadViewController

@property (weak, nonatomic) IBOutlet UIView *viewContain;
@property (weak, nonatomic) IBOutlet UIView *viewImage;
@property (weak, nonatomic) IBOutlet UILabel *lb_version;         //版本信息

@property (weak, nonatomic) IBOutlet UILabel *lb_APPRIGHT;        //版权归属
@property (weak, nonatomic) IBOutlet UILabel *lb_TECHNICALSUPPORT;//技术支持
@property (weak, nonatomic) IBOutlet UILabel *lb_CUSTPHONE;       //客服电话

//图片Logo
@property (weak, nonatomic) IBOutlet UIImageView *view_Default;
@property (weak, nonatomic) IBOutlet UIImageView *view_Left;
@property (weak, nonatomic) IBOutlet UIImageView *view_Right;

@end
