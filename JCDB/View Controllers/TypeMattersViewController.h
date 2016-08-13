//
//  TypeMattersViewController.h
//  JCDB
//
//  Created by WangJincai on 16/3/29.
//  Copyright © 2016年 wjc. All rights reserved.
//


#import "HeadViewController.h"

@interface TypeMattersBean : NSObject

@property (nonatomic,strong) NSString *formid;
@property (nonatomic,strong) NSString *objid;
@property (nonatomic,strong) NSString *ismobile;
@property (nonatomic,strong) NSString *listsize;
@property (nonatomic,strong) NSString *moduleid;
@property (nonatomic,strong) NSString *objname;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *type;

@end

@interface TypeMattersViewController : HeadViewController

@property (nonatomic,strong) NSArray *listData;

@end
