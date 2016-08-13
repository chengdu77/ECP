//
//  TreeDeptViewController.h
//  JCDB
//
//  Created by WangJincai on 16/6/5.
//  Copyright © 2016年 wjc. All rights reserved.
//

#import "HeadViewController.h"



typedef void(^TreeDeptBlock)(NSArray *ids,NSArray *names);

@interface TreeDeptViewController : HeadViewController

@property (nonatomic,assign) BOOL isRadioFlag;
@property (nonatomic,strong) NSArray *defaultDepts;//默认部门
@property (nonatomic,copy) TreeDeptBlock block;

- (void)setTreeDeptBlock:(TreeDeptBlock) block;

@end
