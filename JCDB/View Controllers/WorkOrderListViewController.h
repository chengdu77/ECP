//
//  WorkOrderListViewController.h
//  JCDB
//
//  Created by WangJincai on 16/1/4.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import "HeadViewController.h"

@interface WorkOrderListViewController : HeadViewController


@property (nonatomic,strong) NSString *state;
@property (nonatomic,assign) NSInteger moduleFlag;//0表示事项，1表示项目管理，2表示形象进度

@end
