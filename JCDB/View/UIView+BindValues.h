//
//  UIView+BindValues.h
//  JCDB
//
//  Created by WangJincai on 16/1/6.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (BindValues)

@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString* value;
@property (nonatomic, strong) NSString* newValue;
@property (nonatomic, strong) NSString *fieldType;
@property (nonatomic, strong) NSArray *pulldownData;
@property (nonatomic, strong) NSString *viewListTitle;
@property (nonatomic, strong) NSString *tablename;
@property (nonatomic, strong) NSString *fieldname;

@property (nonatomic, strong) NSString *labelname;
@property (nonatomic, strong) NSString *must;//必填
@property (nonatomic, strong) NSString *bemulti;

@property (nonatomic, strong) id node;

@property (nonatomic, strong) NSString *browserid;

@property (nonatomic, strong) NSString *datatype;


@property (nonatomic, assign) NSInteger *cnt;

@end
