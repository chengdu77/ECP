//
//  WorkOrderBean.h
//  JCDB
//
//  Created by WangJincai on 16/1/4.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WorkOrderBean : NSObject

@property (nonatomic,strong) NSString *createdate;
@property (nonatomic,strong) NSString *creator;
@property (nonatomic,strong) NSString *currentnode;
@property (nonatomic,strong) NSString *dowid;
@property (nonatomic,strong) NSString *downame;
@property (nonatomic,strong) NSString *_id;
@property (nonatomic,strong) NSString *lastcreatedate;
@property (nonatomic,strong) NSString *lastcreator;
@property (nonatomic,strong) NSString *processid;
@property (nonatomic,strong) NSString *status;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *iconnew;

@end

@interface ScheduleBean : NSObject

@property (nonatomic,strong) NSString *Customer;
@property (nonatomic,strong) NSString *begindate;// 开始日期
@property (nonatomic,strong) NSString *begintime;
@property (nonatomic,strong) NSString *bumen;
@property (nonatomic,strong) NSString *creator;
@property (nonatomic,strong) NSString *enddate;//结束日期
@property (nonatomic,strong) NSString *endtime;
@property (nonatomic,strong) NSString *event;//内容
@property (nonatomic,strong) NSString *processid;
@property (nonatomic,strong) NSString *title;//标题

@end

@interface WorkReportBean : NSObject

@property (nonatomic,strong) NSDictionary *attachments;
@property (nonatomic,strong) NSString *datatime;
@property (nonatomic,strong) NSString *dept;
@property (nonatomic,strong) NSString *filename;
@property (nonatomic,strong) NSNumber *leader;
@property (nonatomic,strong) NSString *message;
@property (nonatomic,strong) NSString *operator_;
@property (nonatomic,strong) NSString *opertype;
@property (nonatomic,strong) NSString *point;
@property (nonatomic,assign) BOOL isExtendFlag;
@end


