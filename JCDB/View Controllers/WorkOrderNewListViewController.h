//
//  WorkOrderNewListViewController.h
//  JCDB
//
//  Created by WangJincai on 16/9/29.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "HeadViewController.h"

@interface WorkOrderNewListViewController : HeadViewController

@property (nonatomic,strong) NSString *state;
@property (nonatomic,assign) NSUInteger index;

@property (nonatomic,assign) NSInteger moduleFlag;//0表示事项，1表示项目管理，2表示形象进度


- (void)businessWithIndex:(NSString *)workflowid_;
@end
