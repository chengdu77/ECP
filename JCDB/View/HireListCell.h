//
//  SubViewController.m
//  WJcTableView
//
//  Created by wangjc on 15-7-4.
//  Copyright (c) 2015年 wjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HireListCell : UITableViewCell
@property (nonatomic,strong) IBOutlet UILabel *titleLabel;
@property (nonatomic,strong) IBOutlet UILabel *dateLabel;

- (void)changeArrowWithUp:(BOOL)up;
@end
