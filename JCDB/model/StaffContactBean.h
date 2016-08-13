//
//  StaffContactBean.h
//  JCDB
//
//  Created by WangJincai on 16/1/2.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StaffContactBean : NSObject

@property (nonatomic,strong) NSString *tel;
@property (nonatomic,strong) NSString *duty;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *gender;
@property (nonatomic,strong) NSString *_id;
@property (nonatomic,strong) NSString *org;
@property (nonatomic,strong) NSString *photoURL;
@property (nonatomic,strong) NSString *photoId;
@property (nonatomic,strong) NSString *photoZN;
@property (nonatomic,strong) NSString *processid;
@property (nonatomic,assign) NSUInteger daiban;
@property (nonatomic,assign) NSUInteger qqwwc;
@property (nonatomic,assign) NSUInteger yiban;

@property(nonatomic,strong) NSString *NAME_PINYIN;// 姓名拼音
@property(nonatomic,strong) NSString *NAME_HEAD;  // 姓名首字母
@end
