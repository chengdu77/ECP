//
//  WorkOrderDetailsViewController.h
//  JCDB
//
//  Created by WangJincai on 16/1/5.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import "HeadViewController.h"

@interface WorkOrderDetailsViewController : HeadViewController

@property (nonatomic,assign) BOOL canEditFlag;//只有待办，才有权利做编辑操作
@property (nonatomic,strong) NSString *processid;
@property (nonatomic,strong) NSString *currentnode;
@property (nonatomic,assign) BOOL hasFavorite;

@property (nonatomic,assign) NSUInteger type;//1工作台;其它type=2;

@property (nonatomic,copy) SuccessRefreshViewBlock block;

- (void)setSuccessRefreshViewBlock:(SuccessRefreshViewBlock) block;

@end
