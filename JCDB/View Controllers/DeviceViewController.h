//
//  DeviceViewController.h
//  xsgj
//
//  Created by 卿 明 on 15/11/3.
//  Copyright (c) 2015年 Shenlan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeadViewController.h"


typedef void(^DeviceTypeBlock)(NSInteger deviceId,NSString *deviceName);

@interface DeviceViewController : HeadViewController

@property (nonatomic,strong) NSArray *infos;
@property (nonatomic,copy) DeviceTypeBlock block;
-(void)setDeviceTypeBlock:(DeviceTypeBlock) block;

@end
