//
//  HeadView.h
//  Test04
//
//  Created by HuHongbing on 9/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ProcessStatusHeadViewDelegate;

@interface ProcessStatusHeadView : UIView

@property(nonatomic, assign) id<ProcessStatusHeadViewDelegate> delegate;
@property(nonatomic, assign) NSInteger section;
@property(nonatomic, assign) BOOL open;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, assign) NSInteger statusListCount;
@end

@protocol ProcessStatusHeadViewDelegate <NSObject>
-(void)selectedWith:(ProcessStatusHeadView *)view;
@end
