//
//  JGGLabel.m
//  九宫格
//
//  Created by mj on 14-9-9.
//  Copyright (c) 2014年 Mr.Li. All rights reserved.
//

#import "JGGLabel.h"

@implementation JGGLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat myLabelW = 150;
        CGFloat myLabelY = 300;
        CGFloat myLabelH = 30;
        CGFloat myLabelX = (320 - myLabelW) / 2;
        self.frame = CGRectMake(myLabelX, myLabelY, myLabelW, myLabelH);
        self.backgroundColor = [UIColor lightGrayColor];
        self.font = [UIFont systemFontOfSize:13];
        self.textColor = [UIColor whiteColor];
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}


@end
