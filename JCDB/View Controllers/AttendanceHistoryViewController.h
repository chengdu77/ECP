//
//  AttendanceHistoryViewController.h
//  JCDB
//
//  Created by WangJincai on 16/7/12.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "HeadViewController.h"

@interface AttendanceHistoryBean : NSObject

@property (nonatomic,strong) NSString *date;
@property (nonatomic,strong) NSString *day;
@property (nonatomic,strong) NSString *deptid;
@property (nonatomic,strong) NSString *deptname;
@property (nonatomic,strong) NSString *Id;
@property (nonatomic,strong) NSString *jingweidu;
@property (nonatomic,strong) NSString *space;
@property (nonatomic,strong) NSString *time;
@property (nonatomic,strong) NSString *userid;
@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) NSString *week;
@end


@interface AttendanceHistoryViewController : HeadViewController

@property (nonatomic,strong) NSArray *listArray;
@end
