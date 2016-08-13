//
//  AppendixDetailsViewController.h
//  JCDB
//
//  Created by WangJincai on 16/1/8.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import "HeadViewController.h"
typedef void(^SuccessReturnBlock)(id object);//NSMutableArray *data

@interface AppendixDetailsViewController : HeadViewController

@property (nonatomic,assign) BOOL canEditFlag;
@property (nonatomic,strong) NSArray *formFields;
@property (nonatomic,copy) SuccessReturnBlock block;

- (void)setSuccessReturnBlock:(SuccessReturnBlock) block;

- (id)initData:(NSArray *)arr;

@end
