//
//  SelectionModuleViewController.h
//  JCDB
//
//  Created by WangJincai on 16/3/29.
//  Copyright © 2016年 wjc. All rights reserved.
//

/*选择模块*/

#import "HeadViewController.h"

@interface SelectionModuleBean : NSObject
@property (nonatomic,strong) NSString *cnum;
@property (nonatomic,strong) NSString *objid;
@property (nonatomic,strong) NSString *objname;

@end;

@interface SelectionModuleViewController : HeadViewController


@property (nonatomic,strong) NSArray *listData;

@end
