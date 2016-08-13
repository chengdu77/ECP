//
//  MyView.h
//  九宫格
//
//  Created by mj on 14-9-9.
//  Copyright (c) 2014年 Mr.Li. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^JGGButtonBlock)();
@class JGGModel;

@interface JGGView : UIView

@property (nonatomic, strong) JGGModel *model;
@property (nonatomic, strong) UILabel *redPountLabel;

- (id)initWithFrame:(CGRect)frame Model:(JGGModel *)model MyButtonBlock:(JGGButtonBlock)myButtonBlock;

@end
