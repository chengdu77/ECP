//
//  SignViewController.h
//  JCDB
//
//  Created by WangJincai on 16/1/21.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import "HeadViewController.h"


@interface SignViewController : HeadViewController

@property (nonatomic,strong) NSString *action;
@property (nonatomic,strong) NSDictionary *info;
@property (nonatomic,strong) NSString *maintable;
@property (nonatomic,strong) NSString *processid;
@property (nonatomic,strong) NSDictionary *tables;
@property (nonatomic,strong) NSString *rejecttonode;

@property (nonatomic,copy) SuccessRefreshViewBlock block;

- (void)setSuccessRefreshViewBlock:(SuccessRefreshViewBlock) block;

@end
