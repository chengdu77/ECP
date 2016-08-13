//
//  ProcessStatusHeadView.m
//  Test04
//
//  Created by HuHongbing on 9/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProcessStatusHeadView.h"
#import "Constants.h"

@implementation ProcessStatusHeadView


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.open = NO;
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,(CGRectGetHeight(frame)-20)/2,120,20)];
        self.titleLabel.font = [UIFont fontWithName:kFontName size:14];
        [self addSubview:self.titleLabel];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)-30,(CGRectGetHeight(frame)-20)/2,20,20)];
        self.imageView.image = [UIImage imageNamed:@"img_wf_log_b"];
        [self addSubview:self.imageView];
        
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *viewTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doSelected)];
        [self addGestureRecognizer:viewTapGesture];
    }
    return self;
}

-(void)doSelected{

    if (_delegate && [_delegate respondsToSelector:@selector(selectedWith:)]){
     	[_delegate selectedWith:self];
    }
}
@end
